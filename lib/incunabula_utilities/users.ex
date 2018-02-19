defmodule IncunabulaUtilities.Users do

  use GenServer

  @moduledoc """

  Some of these functions are designed to be used in the main Incunabula
  and some in the command line escript to create the admin user

  The reason for this is that to avoid having a default insecure password
  this is a utility for generating the intial login on the command line
  using an escript so user stuff covers two different worlds

  The main user module runs as a gen server to provide serialisation
  """

  @usersDB "users.db"
  @timeout 5_000

  require Logger

  #
  # Gen Server API
  #

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, []}
  end

  #
  # Incunabula API
  #

  def get_users() do
    GenServer.call(__MODULE__, :get_users, @timeout)
  end

  def is_login_valid?(username, password) do
    GenServer.call(__MODULE__, {:is_login_valid?, username, password}, @timeout)
  end

  def change_password(username, password) do
    GenServer.call(__MODULE__, {:change_password, username, password}, @timeout)
  end

  def add_user(username, password) do
    GenServer.call(__MODULE__, {:add_user, username, password}, @timeout)
  end

  def delete_user(username) do
    GenServer.call(__MODULE__, {:delete_user, username}, @timeout)
  end

  #
  # Gen Server exports
  #

    def handle_call(:get_users, _from, state) do
    dir = get_users_dir()
    reply = IncunabulaUtilities.DB.lookup_values(dir, @usersDB, :username)
    {:reply, reply, state}
  end

  def handle_call({:is_login_valid?, username, password}, _from, state) do
    dir = get_users_dir()
    reply = case IncunabulaUtilities.DB.lookup_value(dir, @usersDB, :username,
                  username, :passwordhash) do
              {:ok, hash} ->
                Pbkdf2.verify_pass(password, hash)
              {:error, _err} ->
                false
            end
    {:reply, reply, state}
  end

  def handle_call({:change_password, username, password}, _from, state) do
    reply = case is_password_valid?(password) do
              true ->
                dir = get_users_dir()
                case is_existing_user?(dir, username) do
                  true ->
                    hash = Pbkdf2.hash_pwd_salt(password)
                    ^dir = IncunabulaUtilities.DB.update_value(dir, @usersDB,
                      :username, username, :passwordhash, hash)
                    :ok
                  false ->
                    {:error, "user doesn't exist"}
                end
              false ->
                {:error, "password is not valid"}
            end
    {:reply, reply, state}
  end

  def handle_call({:add_user, username, password}, _from, state) do
    reply = case is_password_valid?(password) do
              true ->
                dir = get_users_dir()
                do_add_user(dir, username, password)
              false ->
                {:error, "password is not valid"}
            end
    {:reply, reply, state}
  end

  def handle_call({:delete_user, username}, _from, state) do
    dir = get_users_dir()
    reply = IncunabulaUtilities.DB.delete_records(dir, @usersDB,
      :username, username)
    {:reply, reply, state}
  end

  #
  # add user escript API
  #

  def is_password_valid?(password)
  when byte_size(password) > 9
  and  byte_size(password) < 121 do
    true
  end

  def is_password_valid?(_) do
    false
  end

  def add_user_for_escript(username, password) do
    dir = "./"
    do_add_user(dir, username, password)
  end

  #
  # Private fns
  #

  defp do_add_user(dir, username, password) do
    hash = Pbkdf2.hash_pwd_salt(password)
    newrecord = make_record(username, hash)
    file = @usersDB
    case is_existing_user?(dir, username) do
      true ->
        {:error, "user already exists"}
      false ->
        ^dir = IncunabulaUtilities.DB.appendDB(dir, file, newrecord)
        :ok
    end
  end

  def is_existing_user?(dir, username) do
   case IncunabulaUtilities.DB.lookup_value(dir, @usersDB, :username,
      username, :username) do
     {:ok, ^username}           -> true
     {:error, :no_match_of_key} -> false
   end
  end

  defp make_record(username, passwordhash) do
    _newrecord = %{username:     username,
                   passwordhash: passwordhash}
  end

  defp get_users_dir() do
    _dir = Path.join(get_env(:root_directory), "users")
  end

  # yes these utilities are only designed to work with incunabula
  # therefore they depend on the incunabala config files
  defp get_env(key) do
    configs = Application.get_env(:incunabula, :configuration)
    configs[key]
  end

end

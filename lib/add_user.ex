defmodule AddUser do

  @moduledoc """
  "This module is compiled to an escript to create users on the command line"
  """

  @usersDB "users.db"

  def main(args) do
    args
    |> parse_args
    |> process
    :ok
  end

  defp process(:help) do
    help()
  end

  defp process({name, password}) do
    case is_password_valid?(password) do
      true  -> case File.exists?("./" <> @usersDB) do
                 :true  -> add_user(name, password)
                 :false -> create_file(name, password)
               end
      false -> help()
    end
  end

  # this is here and not in users because it doesn't know what dir to be in
  def add_user(username, password) do
    hash = Pbkdf2.hash_pwd_salt(password)
    newrecord = IncunabulaUtilities.Users.make_record(username, hash)
    dir = "./"
    file = @usersDB
    ^dir = IncunabulaUtilities.DB.appendDB(dir, file, newrecord)
  end

  defp create_file(username, password) do
    dir = "./"
    file = "users.db"
    ^dir = IncunabulaUtilities.DB.createDB(dir, file)
    add_user(username, password)
    end

  defp is_password_valid?(password)
  when byte_size(password) > 9
  and  byte_size(password) < 121 do
    true
  end

  defp is_password_valid?(_) do
    false
  end

  defp parse_args(args) do
    case OptionParser.parse(args) do
      {[], [name, password], []} ->
        {name, password}
      _ ->
        :help
    end
  end

  defp help() do
    IO.puts """
    Purpose
    -------
    * if the user doesn't exist this creates a new user/password
    * if the user exists it overwrites their password

    Change directory to the incunabula directory priv/users
    * if there is a file users.db in there the user will be added to it
    * if there is not then a new file will be created

    Usage
    -----
    >./add_user username password

    Password Restrictions
    ---------------------
    The password must be:
    * between 10 and 120 characters long

    If you create a user called 'admin' with an admin password
    then you can do subsequent user administration on the main site
    ie add and delete users, reset their passwords
    """
  end

end

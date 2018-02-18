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

  defp process({username, password}) do
    case is_password_valid?(password) do
      true  -> case File.exists?("./" <> @usersDB) do
                 :true  -> add_user(username, password)
                 :false -> create_file(username, password)
               end
      false -> help()
    end
  end

  defp create_file(username, password) do
    dir = "./"
    file = "users.db"
    ^dir = IncunabulaUtilities.DB.createDB(dir, file)
    add_user(username, password)
    end

  defp add_user(username, password) do
    IncunabulaUtilities.Users.add_user_for_escript(username, password)
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

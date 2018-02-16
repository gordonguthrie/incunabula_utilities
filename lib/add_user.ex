defmodule AddUser do

  @moduledoc """
  "This module is compiled to an escript to create users on the command line"
  """

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
      true  -> case File.exists?("users.db") do
                        :true  -> add_user(name, password)
                        :false -> create_file(name, password)
                      end
      false -> help()
    end
  end

  defp add_user(name, password) do
    {:ok, usersandhashes} = :file.consult("./users.db")
    hash = Pbkdf2.hash_pwd_salt(password)
    newuandh = List.keystore(usersandhashes, name, 0, {name, hash})
    :ok = write_file(newuandh)
  end

  defp create_file(name, password) do
    hash = Pbkdf2.hash_pwd_salt(password)
    payload = [{name, hash}]
    :ok = write_file(payload)
  end

  defp write_file(payload) do
    fileformat = :io_lib.format('~p.~n', [payload])
    :ok = File.write("./users.db", fileformat)
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
    """
  end

end

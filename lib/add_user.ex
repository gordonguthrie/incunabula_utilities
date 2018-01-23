defmodule AddUser do

  @moduledoc """
  "This module is compiled to an escript to create users on the command line"
  """

  def main(args) do
    args
    |> parse_args
    |> process
  end

  defp process(:help) do
    help()
  end

  defp process({name, password}) do
    IO.puts name
    IO.puts password
    case is_password_valid?(password) do
      true  -> case File.exists?("users.config") do
                        :true  -> add_user(name, password)
                        :false -> create_file(name, password)
                      end
      false -> help()
    end
  end



  defp add_user(name, password) do
    #        path = Path.join(:code.priv_dir(:incunabula), "users/users.config")
    #    {:ok, [users: users]} = :file.consult(path)
    IO.puts "fix up"
  end

  defp create_file(name, password) do
    IO.puts "fix up II"
  end

  def is_password_valid?(password) do
    true
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
    Creates a new user/password

    Change directory to the incunabula directory priv/users
    * if there is a file users.config in there the user will be added to it
    * if there is not then a new file will be created

    Usage
    -----
    >./add_user username password

    Password Restrictions
    ---------------------
    The password must be:
    *
    """
  end

end

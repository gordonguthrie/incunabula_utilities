defmodule IncunabulaUtilities.Users do

@usersDB "users.db"

#
# some of these functions are designed to be used in the main Incunabula
# and some in the command line escript to create the admin user

def get_users() do
    dir = get_users_dir()
    IncunabulaUtilities.DB.lookup_values(dir, @usersDB, :username)
  end

  def is_login_valid(username, password) do
  dir = get_users_dir()
  case IncunabulaUtilities.DB.lookup_value(dir, @usersDB, :username,
      username, :passwordhash) do
      {:ok, hash} ->
        Pbkdf2.verify_pass(password, hash)
      {:error, _err} ->
        false
    end
  end

  def make_record(username, passwordhash) do
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

defmodule IncunabulaUtilities.Users do

  def get_users() do
    usersandhashes = get_users_and_hashes()
    for {user, _password} <- usersandhashes, do: user
  end

  def is_login_valid(username, password) do
    usersandhashes = get_users_and_hashes()
    case List.keyfind(usersandhashes, username, 0) do
      nil             ->
        false
      {_, hash} ->
        IO.inspect "checking password"
        IO.inspect password
        IO.inspect hash
        #IO.inspect Comeonin.Pbkdf2.checkpw(password, hash)
        IO.inspect "returning"
        # IO.inspect ret
    end
  end

    def get_users_and_hashes() do
    path = Path.join(:code.priv_dir(:incunabula), "users/users.db")
    {:ok, [users: users]} = :file.consult(path)
    users
  end

end

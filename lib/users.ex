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
        Pbkdf2.verify_pass(password, hash)
    end
  end

  def get_users_and_hashes() do
    path = Path.join(Incunabula.Git.get_books_dir(), "../users/users.db")
    {:ok, users} = :file.consult(path)
    users
  end

end

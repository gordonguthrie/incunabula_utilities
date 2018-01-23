defmodule AddUser.Mixfile do
  use Mix.Project

  def project do
    [app: :add_users,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "add users for Incunabula",
     package: package,
     escript: escript,
     deps: deps]
  end

  defp escript do
    [main_module: AddUser, embed_elixir: true]
  end

  def application, do: [applications: []]

  defp deps do
    [
      {:comeonin,            "~> 4.0"},
      {:pbkdf2_elixir,       "~> 0.12.3"}
    ]
  end

  defp package do
    [maintainers: ["Gordon Guthrie"],
     licenses: ["GLP V.30"],
     links: %{"GitHub" => "https://github.com/gordonguthrie/incunabula_utilities"}]
  end
end

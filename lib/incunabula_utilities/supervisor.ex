defmodule IncunabulaUtilities.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(params) do
    IO.inspect "in init for supervisor"
    IO.inspect params
    children = [
      worker(IncunabulaUtilities.Users, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end

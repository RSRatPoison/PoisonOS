defmodule PoisonOS.Application do
  @moduledoc """
  Application supervisor for PoisonOS.

  Starts the core services in a supervision tree.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PoisonOS.IPC
    ]

    opts = [strategy: :one_for_one, name: PoisonOS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

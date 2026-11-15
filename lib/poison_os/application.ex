defmodule PoisonOS.Application do
  @moduledoc """
  The OTP application callback module for **PoisonOS**.

  It starts a supervision tree that contains the core services required by the
  operating‑system layer.  Currently the only child is the IPC subsystem, but
  additional services can be added to the `children` list as the project grows.

  The supervisor is started with a `:one_for_one` strategy and is registered
  under the name `PoisonOS.Supervisor`.
  """

  use Application

  @doc """
  Starts the application supervision tree.

  This callback is invoked by the runtime when the application is started.
  It builds a list of child specifications and starts a supervisor with the
  given options.

  ## Parameters

    * `_type` – the start type, ignored in this implementation.
    * `_args` – start arguments, ignored in this implementation.

  ## Return value

  Returns `{:ok, pid}` on success where `pid` is the supervisor's PID, or
  `{:error, reason}` if the supervisor could not be started.
  """
  @spec start(term(), term()) :: {:ok, pid()} | {:error, term()}
  @impl true
  def start(_type, _args) do
    children = [
      PoisonOS.IPC
    ]

    opts = [strategy: :one_for_one, name: PoisonOS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

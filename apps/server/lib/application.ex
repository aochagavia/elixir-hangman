defmodule Server.Application do
  use Application

  def start(_type, _args) do
    children = [
      Server.Tcp.ConnectionMonitor,
      Server.Tcp.ConnectionListener
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

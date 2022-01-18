defmodule DsaStack.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: port(), dispatch: dispatch()]},
      {Registry, keys: :unique, name: Registry.DsaStack},
      {Registry,
       keys: :duplicate, name: Registry.MeetingPubSub, partitions: System.schedulers_online()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DsaStack.Supervisor]

    # Logger.info("The server listening at port: #{port()}")
    :ets.new(:player_keys, [:set, :public, :named_table])
    Supervisor.start_link(children, opts)
  end

  # Call environment variables here.
  defp port, do: Application.get_env(:app, :port, 8000)

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", SocketHandler, []}
       ]}
    ]
  end
end

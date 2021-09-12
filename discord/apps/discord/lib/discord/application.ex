defmodule Discord.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias ExHashRing.Ring

  @websocket_config  [
    port: 4000,
    dispatch_matches: [
      {:_, Plug.Cowboy.Handler, { DiscordFoundation.Socket.Endpoint, []}}
    ],
    handler: [
      output_processors: [

      ]
    ],
  ]








  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Discord.Worker.start_link(arg)
      # {Discord.Worker, arg}
      Supervisor.child_spec({Ring, [name: :userRing]}, id: :userRing),

      {Discord.Server.DynamicSupervisor,[name: :serversupervisor ] },
      websocket_listener(@websocket_config),
      {Discord.MongoWatch.Supervisor,[name: :mongowatchsupervisor]},
      {Discord.SocketEventHandler.Supervisor,[name: :socketeventhandlersupervisor]},
      {Task.Supervisor,[name: :tasksupervisor]},
      {Discord.Chief.MasterServer,[name: :masterserver]},
#      {Discord.Chief.MasterServer,[{:global, :masterserver}]}
      {Ring,[name: {:global,:serverring}]},
#      {Ring,[name: :userRing]},


    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Discord.Supervisor]
    Supervisor.start_link(children, opts)
  end






  def websocket_listener(websocket_config) do
    config = Application.get_env(:kantele, :listener, [])

    case Keyword.get(config, :start, true) do
      true ->
        {DiscordFoundation.Socket.Listener, websocket_config}

      false ->
        nil
    end
  end







end

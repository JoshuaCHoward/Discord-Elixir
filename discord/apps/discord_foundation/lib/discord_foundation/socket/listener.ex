defmodule DiscordFoundation.Socket.Listener do
  @moduledoc false

  use Supervisor
  def start_link(opts) do
    opts = Enum.into(opts, %{})
    Supervisor.start_link(__MODULE__, opts, Map.get(opts, :otp, []))
  end


  def init(config) do
    children = [Plug.Cowboy.child_spec(
    scheme: :http,
    plug: DiscordFoundation.Socket.Endpoint,
      options: [port: config[:port], dispatch: dispatch(config)]
    ),
      {Redix,host: "redis-16848.c253.us-central1-1.gce.cloud.redislabs.com", password: "ToTestMe1!", username: "ToTestMe",port: 16848, name: :redix},
    ]
    Supervisor.init(children, strategy: :one_for_one)

  end

  defp dispatch(config) do

    dispatch_matches = Map.get(config, :dispatch_matches, [])


    IO.puts("AHH")
    [
      {:_,
        [
          {"/websocket",  DiscordFoundation.Socket.Handler,[]}
          | dispatch_matches
        ]}
    ]
  end

end

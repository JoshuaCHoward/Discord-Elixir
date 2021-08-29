defmodule DiscordFoundation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: DiscordFoundation.Worker.start_link(arg)
      # {DiscordFoundation.Worker, arg}
      {Mongo,[url: "mongodb+srv://mongo:test@discordgroup.n0ujo.mongodb.net/myFirstDatabase?retryWrites=true&w=majority", name: :mongo]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DiscordFoundation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Discord.Server.DynamicSupervisor do

  @moduledoc false

  use DynamicSupervisor
  require Supervisor
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_server(id) do
    # This will start child by calling MyWorker.start_link(init_arg, foo, bar, baz)

    IO.inspect("HULKK SMASHHHH")

    spec=Supervisor.child_spec({Discord.Server.Core,[:start_link]},id: id)
    IO.inspect(spec)
    DynamicSupervisor.start_child(:serversupervisor, spec)
    IO.inspect("Detriment")
  end


end

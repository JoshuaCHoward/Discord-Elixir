defmodule Discord.Server.DynamicSupervisor do

  @moduledoc false
  alias ExHashRing.Ring
  require GenServer
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
    IO.inspect("HULKK SMASHHHH")
    IO.inspect(Ring.add_node({:global,:serverring},node()))
    IO.inspect(Ring.add_node({:global,:serverring},node()))
    global_pid=:global.whereis_name(:serverring)
    IO.inspect(:global.whereis_name(:serverring))

    IO.inspect(Ring.find_node(global_pid,id))
    node = Ring.find_node(global_pid,id) |> elem(1)
    IO.inspect(id)
    spec=Supervisor.child_spec({Discord.Server.Core,%{id: id}},id: String.to_atom(id))
    IO.inspect(spec)
    DynamicSupervisor.start_child({:serversupervisor,node}, spec)

    IO.inspect("Detriment")

  end


end

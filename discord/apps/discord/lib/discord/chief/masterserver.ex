defmodule Discord.Chief.MasterServer do
  @moduledoc false


  use GenServer
  alias ExHashRing.Ring

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks



  @impl true
  def init(stack) do
    IO.inspect("")
    stack=%{online: %{}}
    IO.inspect(:erlang.system_info(:logical_processors_available))
    IO.inspect([1..:erlang.system_info(:logical_processors_available)])
    cores=Enum.map(1..:erlang.system_info(:logical_processors_available), fn x -> x  end)
    Ring.add_nodes(:userRing,cores)
    {:ok, stack}

  end

  def handle_call({:message,guild_id,channel,message,sendList},_from, state) do
    IO.inspect("Failure")
    IO.inspect(sendList)
#    TODO: section off workers to number of processors on system just so scheduling buffer doesn't kill itself
    #    sectionedMessages=%{}

#    Enum.each(sendList, fn x ->
#      coreGroup=Ring.find_node(:userRing,x)
#      IO.inspect(coreGroup)
#      sectionedMessages=sectionedMessages
#
#    end)
#
    Enum.each(sendList, fn x ->
    address_connections=:ets.lookup(:socket_connection_registry,x)
    IO.inspect("JuJustu Kaisen")
    Enum.each(address_connections, fn  connection_tuple->
        pid=connection_tuple |> elem(1)
        send(pid, {:message,guild_id,channel,message})
    end)


    end)


    {:reply,state, state}
    end


  end
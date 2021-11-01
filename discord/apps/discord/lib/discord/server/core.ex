defmodule Discord.Server.Core do
  @moduledoc false

  use GenServer

  def start_link(state) do
    IO.inspect(state)
    IO.inspect("Hero Killer")
    GenServer.start_link(__MODULE__, state, name: String.to_atom(state.id))
  end

  ## Callbacks



  @impl true
  def init(stack) do
#    stack=%{online: MapSet.new()}
    stack=%{online: %{}}

    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

#  @impl true
#  def handle_call({:push,{x,node}},_from, state) do
#    IO.inspect("YARE YARE")
#    state=%{state|online: MapSet.put(state.online,x)}
#    {:reply, MapSet.to_list(state.online),state}
#  end



  @impl true
  def handle_call({:push,{x,node}},_from, state) do
    IO.inspect("YARE YARE")
#    state.online=Keyword.put(state.online,node,[x|currentOnlineList])
    online=Map.update(state.online,node, [x],fn existing_value ->
      case existing_value do
        _->[x|existing_value]
      end
      end)

#    online=cond do
#      online==[] ->[x]
#      true->online
#    end
    IO.inspect("NEMO")
    IO.inspect(state.online)
    IO.inspect(online)
    IO.inspect(List.flatten(Map.values(online)))
    state=%{state|online: online}
    {:reply, List.flatten(Map.values(online)),state}
  end


  @impl true
  def handle_call({:pop,{node,address,pid}},_from, state) do
    IO.inspect("YARE YARE")
    #    state.online=Keyword.put(state.online,node,[x|currentOnlineList])
    online=Map.update(state.online,node, [],fn existing_value ->
      case existing_value do
        _ -> Enum.reject(existing_value, fn online_user ->
          IO.inspect("Leave Me Alone")
          IO.inspect(address)
          IO.inspect(online_user)
        online_user==address
        end)

      end
    end)


    IO.inspect("NEMO")
    IO.inspect(state.online)
    IO.inspect(online)
    IO.inspect(List.flatten(Map.values(online)))
    state=%{state|online: online}
    {:reply, List.flatten(Map.values(online)),state}
  end





  @impl true
  def handle_call({:message,channel,message},_from, state) do
    IO.inspect("BADBOYS")
    IO.inspect(self())
    guild_id=Keyword.get(Process.info(self()),:registered_name)
    IO.inspect(state.online)
    keys=Map.keys(state.online)
    Enum.map(keys, fn x->
      messageReturn=GenServer.call({Discord.Chief.MasterServer,node},{:message, guild_id, channel, message,state.online[x]})
      state.online[x]
    end)
    {:reply, state.online,state}
  end



  @impl true
  def handle_cast({:push, head}, state) do
    {:noreply,%{state | online: [head | state.online]}}
  end

  def handle_in(x) do

  end
end

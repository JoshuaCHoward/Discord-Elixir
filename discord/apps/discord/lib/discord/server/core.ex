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
    stack=%{online: MapSet.new()}
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call({:push,x},_from, state) do
    IO.inspect("YARE YARE")
    state=%{state|online: MapSet.put(state.online,x)}
    {:reply, MapSet.to_list(state.online),state}
  end

  @impl true
  def handle_call({:message,channel,message},_from, state) do
    IO.inspect("BADBOYS")
    {:reply, MapSet.to_list(state.online),state}
  end



  @impl true
  def handle_cast({:push, head}, state) do
    {:noreply,%{state | online: [head | state.online]}}
  end

  def handle_in(x) do

  end
end

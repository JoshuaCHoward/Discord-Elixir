defmodule Discord.Server.Core do
  @moduledoc false

  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks



  @impl true
  def init(stack) do
    IO.inspect("HOLAA")
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, head}, tail) do
    {:noreply, [head | tail]}
  end

  def handle_in(x) do

  end
end

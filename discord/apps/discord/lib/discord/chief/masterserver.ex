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
    {:ok, ring} = Ring.start_link(name: :serverring)
    IO.inspect("NO ONE HERe")
    IO.inspect(ring)
    {:ok, %{ring: ring}}
  end

end
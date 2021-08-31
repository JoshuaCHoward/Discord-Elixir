defmodule Discord.SocketEventHandler.Consumer do
  @moduledoc false
  use GenStage

  def start_link(id) do
    GenStage.start_link(__MODULE__, id)
  end

  def init(id) do
    {:consumer, id, subscribe_to: [{Discord.SocketEventHandler.Producer, max_demand: 1}]}
  end

  def handle_events([event], _from, id) do
    IO.puts("#{id}: received #{event}")
    Process.sleep(500 + :rand.uniform(1000))
    IO.puts("#{id}: finished #{event}")

    {:noreply, [], id}
  end
end

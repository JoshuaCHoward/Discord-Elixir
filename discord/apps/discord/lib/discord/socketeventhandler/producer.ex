defmodule Discord.SocketEventHandler.Producer do
  @moduledoc false
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:producer, {:queue.new(), 0}}
  end

  def handle_demand(incoming, {queue, demand}) do
    IO.inspect(incoming, label: "demand")

    with {item, queue} <- :queue.out(queue),
         {:value, event} <- item do
      {:noreply, [event], {queue, demand}}
    else
      _ -> {:noreply, [], {queue, demand + 1}}
    end
  end

  def handle_cast({:enqueue, event}, {queue, 0}) do
    queue = :queue.in(event, queue)

    {:noreply, [], {queue, 0}}
  end

  def handle_cast({:enqueue, event}, {queue, demand}) do
    queue = :queue.in(event, queue)
    {{:value, event}, queue} = :queue.out(queue)
    {:noreply, [event], {queue, demand - 1}}
  end

  def enqueue(event) do
    GenServer.cast(__MODULE__, {:enqueue, event})
  end
end


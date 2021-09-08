defmodule Discord.MongoWatch.Core do
  @moduledoc false
  


  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks



  @impl true
  def init(stack) do
    spawn(fn-> for_ever(stack,self()) end)

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





  def for_ever(top, monitor) do
    IO.inspect("AHHHHHHHHAHAHAHAH")

#    cursor = Mongo.watch_collection(:mongo, "user_data", [], fn doc -> send(monitor, {:token, doc}) end)
#    cursor |> Enum.each(fn doc ->
#      IO.inspect("BATMAN")
#      IO.inspect(doc)
#      Discord.Server.DynamicSupervisor.start_server(get_in(doc,["fullDocument","guild_id"]))
#      handle_in(doc)
#    end)



  end






  def handle_in(%{"operationType" => "insert", "fullDocument"=> fullDocument}) do

    Discord.SocketEventHandler.Core.upload(fullDocument)

#    Discord.SocketEventHandler.Producer.enqueue(fullDocument)

  end

  def handle_in(x) do

  end
end

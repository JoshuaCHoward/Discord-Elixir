defmodule DiscordFoundation.Socket.Handler do
  @behaviour :cowboy_websocket_handler
  @timeout 2
  alias Cowboy
  alias ExHashRing.Ring

  def init(req, state) do
    IO.puts("YEYE")
    matched_case=case {get_in(req,[:headers,"cookie"])} do
      nil -> raise "No Access Token"
      x ->
        x|> elem(0) |>match_cookie
    end

    case matched_case do
    {:ok,address} ->
      servers=Mongo.find_one(:mongo,"user_schema",%{"_id": address})
      IO.inspect("Yeah")
      IO.inspect(  elem(req[:peer],0))
      Mongo.insert_one(:mongo,"user_data",%{login_time: Tuple.to_list(elem(req[:peer],0)) |> Enum.join(",")})
      IO.puts("Friendless")
      IO.inspect(servers)
      IO.inspect("--------------------------------")

      state = %{age: 5, servers: servers["guilds"],address: address, pid: ""}
      Enum.each(servers["guilds"], fn x->
        Discord.Server.DynamicSupervisor.start_server(x)
        IO.inspect("WHat")
        IO.inspect(String.to_atom(x))
#        mme=GenServer.call(String.to_atom(x),{:push,x})
#        GenServer.call(String.to_atom(x), :pop)
      end)

      {:cowboy_websocket,req,state}
    {:err} ->
        {:err}
    end
  end

  def match_cookie(x) when is_binary(x) do
    "access_token_cookie=" <> token  = x

    access_token=token |> String.split(";") |> List.first
    IO.inspect(x)
    IO.inspect(access_token)
    jwk = %{
      "kty" => "oct",
      "k" => :jose_base64url.encode("secret")
    }
    case JOSE.JWT.verify_strict(jwk,["HS256"],access_token) |> elem(1) |> Map.get(:fields) |> Map.take(["sub","jti"]) do
      %{"sub"=> sub, "jti" => jti} when is_binary(sub) ->
        Redix.command(:redix, ["HMGET", sub, jti])|> elem(1) |>List.first |> if( do: {:ok,sub}, else: {:err})

    end


  end
  def init(_, _req, _opts) do

    {:upgrade, :protocol, :cowboy_websocket}
  end

  #Called on websocket connection initialization.
  def websocket_init( state) do
    send(self(),{:start, state.servers})
    :ets.insert(:socket_connection_registry,{state.address,self()})

    Enum.each(state.servers, fn x->
      IO.inspect(String.to_atom(x))
      onlineList=GenServer.call(String.to_atom(x),{:push,{state.address,node()}})
      #        GenServer.call(String.to_atom(x), :pop)
      IO.inspect("AHHH")
      send(self(),{:online, {x,onlineList}})

      IO.inspect("Weak self")
    end)
    {:ok, %{state | age: 30, pid: self()}}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, "ping"}, req, state) do
    IO.puts("BRO")
    {:reply, {:text, "pong"}, state}
  end


  def websocket_handle({:text, message}, state) do
    IO.puts(message)
    IO.inspect(state)

    case Jason.decode(message) do
      {:ok, json} ->
      handle_in(json,state)
    end
  end

  def handle_in(%{"topic"=> "phoenix","event" => "heartbeat"  }, state) do
    {:reply, {:text, Jason.encode!(%{age: 44, payload: %{status: "ok"}})
    }, state}
  end

  def handle_in(%{"event" => "new_guild" ,"payload"=> payload }, state) do
    IO.puts("Joke")
    state=Map.update!(state,:servers,fn x->
    case payload["data"]["guild_id"] do
      nil->x
      _->[payload["data"]["guild_id"]|x]

    end
    end)

    case payload["data"]["guild_id"] do
      nil->{:err}
      x->  Mongo.update_one!(:mongo, "user_schema" ,%{"_id": state.address}, %{"$push": %{"guilds": payload["data"]["guild_id"] }})
    end

    servers=Mongo.find(:mongo, "guild_schema" ,%{"_id": payload["data"]["guild_id"]},[projection: %{"_id"=> 1, "guild_picture"=> 1, "channels"=>1}]).docs

    IO.puts("Horrible")

    {:reply, {:text, Jason.encode!(%{event: :new_guild,data: %{servers: servers}, payload: %{status: "ok"}})
    }, state}
  end

  def handle_in(%{"topic"=> "phoenix"  }, state) do
    {:reply, {:text, Jason.encode!(%{age: 44,})
    }, state}
  end







  def handle_in(%{"event" => "message" ,"payload"=>%{"data"=> %{"message"=> message,"guild_id" => guildID, "channel"=> channel  } }}, state) do
    IO.puts("Josdsssssssssssssske")
    IO.inspect(message)
    IO.inspect("HEHEHEHE")
    modifiedText=HtmlSanitizeEx.basic_html(String.trim(message))
    IO.inspect(modifiedText)

    Task.Supervisor.start_child(:tasksupervisor,fn->
      Mongo.insert_one(:mongo,"messages",%{guild_id: guildID,channel: channel ,message: modifiedText, _id: UUID.uuid4() })
    end)
#    messageReturn=GenServer.call(String.to_atom(guildID),{:message, channel, message})
    global_pid=:global.whereis_name(:serverring)
    node=Ring.find_node(global_pid,String.to_atom(guildID)) |> elem(1)

    messageReturn=GenServer.call({String.to_atom(guildID),node},{:message, channel, message})

    {:reply, {:text, Jason.encode!(%{event: :message, data: %{}, payload: %{status: :ok}})
    }, state}
    end








  # Format and forward elixir messages to client
  def websocket_info({:start,data}, state) do
    serverList=Mongo.find(:mongo,"guild_schema",  %{"_id": %{"$in" =>data}}, [projection: %{"_id"=> 1, "guild_picture"=> 1, "channels"=>1}]).docs

    IO.inspect(data)

    IO.puts("FIDDLE STICKS")
#    {:reply, {:text, Jason.encode(%{event: :start, payload: %{status: :ok}})}, state}
#      {:reply, {:text, Jason.encode!(%{age: 44, payload: %{status: "ok"}})}, state}

#    {:reply, {:text, Jason.encode(%{event: :start, payload: %{status: :ok}})}, state}
#

    {:reply, {:text, Jason.encode!(%{event: :start, data: %{servers: serverList}, payload: %{status: :ok}})
    }, state}

  end


  def websocket_info({:online,data}, state) do
    IO.inspect(data)
    IO.puts("SHACO STICKS")
    IO.puts("NOT SHACO STICK")
    {:reply, {:text, Jason.encode!(%{event: :online_list, data: %{server: elem(data,0), serverList: elem(data,1) }, payload: %{status: :ok}})
    }, state}

  end


#  def websocket_info({:online,data}, state) do
#    IO.inspect(data)
#    IO.puts("SHACO STICKS")
#
#    {:reply, {:text, Jason.encode!(%{event: :online_list, data: %{server: elem(data,0), serverList: elem(data,1) }, payload: %{status: :ok}})
#    }, state}
#
#  end

  def websocket_info({:message,guild_id,channel,message}, state) do
    IO.puts("YORICK STICKS")
    IO.inspect(guild_id)
    IO.inspect("PEACE")
    {:reply, {:text, Jason.encode!(%{event: :message, data: %{message: message, channel: channel, guild_id: guild_id }, payload: %{status: :ok}})
    }, state}

  end

  # No matter why we terminate, remove all of this pids subscriptions
  def terminate(_reason, _req, state) do
    :ets.delete_object(:socket_connection_registry,{state.address,self()})
    IO.inspect("GOD KILLING SPEAR")
    :ok
  end
end

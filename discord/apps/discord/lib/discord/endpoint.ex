defmodule Discord.Endpoint do
  @moduledoc false
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn,200,"I am alive")
  end


end

defmodule Mongo.Models.Guild do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "guild_schema" do
    field :creator, :string
    field :guild_picture, :string
  end
end

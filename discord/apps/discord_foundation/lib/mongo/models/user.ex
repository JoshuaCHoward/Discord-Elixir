defmodule Mongo.Models.User do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :string, []}
  schema "user_schema" do
    field :guilds, {:array,:integer}
  end
end

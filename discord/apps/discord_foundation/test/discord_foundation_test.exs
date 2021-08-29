defmodule DiscordFoundationTest do
  use ExUnit.Case
  doctest DiscordFoundation

  test "greets the world" do
    assert DiscordFoundation.hello() == :world
  end
end

defmodule CumulusTest do
  use ExUnit.Case
  doctest Cumulus

  test "greets the world" do
    assert Cumulus.hello() == :world
  end
end

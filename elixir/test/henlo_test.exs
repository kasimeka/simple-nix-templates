defmodule HenloTest do
  use ExUnit.Case
  doctest Henlo

  test "greets the fren" do
    assert Henlo.hello() == :fren
  end
end

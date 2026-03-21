defmodule AdminKitTest do
  use ExUnit.Case
  doctest AdminKit

  test "greets the world" do
    assert AdminKit.hello() == :world
  end
end

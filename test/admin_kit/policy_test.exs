defmodule AdminKit.PolicyTest do
  use ExUnit.Case, async: true

  describe "AllowAll" do
    test "allows everything" do
      policy = AdminKit.Policy.allow_all()
      assert policy.can?(nil, :index, %AdminKit.ResourceConfig{})
      assert policy.can?(nil, :delete, %AdminKit.ResourceConfig{})
      assert policy.can?(%{}, :create, %AdminKit.ResourceConfig{})
    end
  end
end

defmodule BlogTest do
  use ExUnit.Case
  doctest Blog

  test "exposes the application name" do
    assert Blog.name() == :blog
  end
end

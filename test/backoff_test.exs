# Path: test/backoff_test.exs
defmodule BackoffTest do
  use ExUnit.Case, async: true
  alias AtprotoFirehoseWs.Backoff

  test "backoff increases and clamps" do
    b = Backoff.new(min: 100, max: 1000, factor: 2.0)
    assert Backoff.next_delay(b) >= 100

    b2 = Backoff.increment(b)
    d2 = Backoff.next_delay(b2)
    assert d2 >= 100

    b3 = b2 |> Backoff.increment() |> Backoff.increment()
    d3 = Backoff.next_delay(b3)
    assert d3 <= 1000
  end

  test "reset sets attempt to zero" do
    b = Backoff.new() |> Backoff.increment() |> Backoff.increment()
    assert Backoff.reset(b).attempt == 0
  end
end


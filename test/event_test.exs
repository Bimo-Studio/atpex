# Path: test/event_test.exs
defmodule EventTest do
  use ExUnit.Case, async: true
  alias AtprotoFirehoseWs.Event

  test "from_map extracts fields" do
    m = %{"$type" => "com.atproto.sync.commit", "seq" => 42, "repo" => "did:plc:abc", "ops" => [%{"action" => "create"}]}
    e = Event.from_map(m)
    assert e.type == "com.atproto.sync.commit"
    assert e.seq == 42
    assert e.repo == "did:plc:abc"
    assert is_list(e.ops)
  end
end


# Path: lib/atproto_firehose_ws/event.ex
defmodule AtprotoFirehoseWs.Event do
  defstruct [:type, :seq, :repo, :ops, :blocks]

  def from_map(map) do
    %__MODULE__{
      type: Map.get(map, "$type") || Map.get(map, "type"),
      seq: Map.get(map, "seq"),
      repo: Map.get(map, "repo"),
      ops: Map.get(map, "ops", []),
      blocks: Map.get(map, "blocks")
    }
  end
end


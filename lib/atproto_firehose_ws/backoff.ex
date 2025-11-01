# Path: lib/atproto_firehose_ws/backoff.ex
defmodule AtprotoFirehoseWs.Backoff do
  defstruct min: 1000, max: 30000, factor: 2.0, attempt: 0

  def new(opts \\ []) do
    %__MODULE__{
      min: Keyword.get(opts, :min, 1000),
      max: Keyword.get(opts, :max, 30000),
      factor: Keyword.get(opts, :factor, 2.0),
      attempt: 0
    }
  end

  def increment(%__MODULE__{attempt: n} = b), do: %{b | attempt: n + 1}
  def reset(%__MODULE__{} = b), do: %{b | attempt: 0}

  def next_delay(%__MODULE__{min: min, max: max, factor: f, attempt: n}) do
    jitter = :erlang.phash2(n, 1000) / 1000.0
    raw = min * :math.pow(f, n) * (1.0 + jitter * 0.5)
    trunc(min(raw, max))
  end
end


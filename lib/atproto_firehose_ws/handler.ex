# Path: lib/atproto_firehose_ws/handler.ex
defmodule AtprotoFirehoseWs.Handler do
  @callback init(opts :: term) :: {:ok, state :: term}
  @callback handle_event(event :: map, state :: term) ::
              {:ok, state :: term} | {:error, reason :: term}
  @callback handle_error(reason :: term, state :: term) ::
              {:ok, state :: term} | {:stop, reason :: term}
end


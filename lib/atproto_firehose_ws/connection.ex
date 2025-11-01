# Path: lib/atproto_firehose_ws/connection.ex
defmodule AtprotoFirehoseWs.Connection do
  use WebSockex
  require Logger
  alias AtprotoFirehoseWs.{Backoff, Decoder, Event}

  defstruct handler: nil, handler_state: nil, backoff: nil, url: nil

  @default_url "wss://bsky.network/xrpc/com.atproto.sync.subscribeRepos"

  def start_link(handler, opts \\ []) when is_atom(handler) do
    url = Keyword.get(opts, :url, @default_url)
    init_state = %__MODULE__{handler: handler, backoff: Backoff.new(), url: url}
    WebSockex.start_link(url, __MODULE__, init_state, name: Keyword.get(opts, :name))
  end

  def stop(pid), do: WebSockex.cast(pid, :close)

  def handle_connect(_conn, state) do
    Logger.info("connected to #{state.url}")
    handler_state = case safe_call_init(state.handler, []) do
      {:ok, s} -> s
      _ -> nil
    end
    {:ok, %{state | handler_state: handler_state, backoff: Backoff.reset(state.backoff)}}
  end

  def handle_cast(:close, state), do: {:close, state}

  def handle_frame({type, payload}, state) when type in [:binary, :text] do
    case type do
      :binary -> handle_binary(payload, state)
      :text -> handle_text(payload, state)
    end
  end

  defp handle_binary(payload, state) do
    case Decoder.decode_cbor(payload) do
      {:ok, decoded} when is_map(decoded) ->
        event = Event.from_map(decoded)
        case safe_handle_event(state.handler, event, state.handler_state) do
          {:ok, new_h_state} -> {:ok, %{state | handler_state: new_h_state}}
          {:error, _} -> safe_handle_error(state.handler, :error, state.handler_state); {:ok, state}
        end
      {:ok, _} -> {:ok, state}
      {:error, reason} -> safe_handle_error(state.handler, reason, state.handler_state); {:ok, state}
    end
  end

  defp handle_text(payload, state) when is_binary(payload) do
    if String.contains?(payload, "rate") or String.contains?(payload, "429") do
      b = %{state.backoff | min: min(state.backoff.max, state.backoff.min * 2)}
      Logger.warn("rate message from server, increasing min backoff to #{b.min}")
      {:ok, %{state | backoff: b}}
    else
      {:ok, state}
    end
  end

  def handle_disconnect(_conn_map, state) do
    b = Backoff.increment(state.backoff)
    delay = Backoff.next_delay(b)
    :timer.sleep(delay)
    {:reconnect, %{state | backoff: b}}
  end

  defp safe_call_init(handler, opts) do
    try do handler.init(opts) rescue e -> {:error, e} end
  end
  defp safe_handle_event(handler, event, hstate) do
    try do handler.handle_event(event, hstate) rescue e -> {:error, e} end
  end
  defp safe_handle_error(handler, reason, hstate) do
    try do handler.handle_error(reason, hstate) rescue _ -> :ok end
  end
end


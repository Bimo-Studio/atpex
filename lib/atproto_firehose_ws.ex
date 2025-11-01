# Path: lib/atproto_firehose_ws.ex
defmodule AtprotoFirehoseWs do
  alias AtprotoFirehoseWs.Connection

  @spec start_link(module(), keyword()) :: Supervisor.on_start()
  def start_link(handler, opts \\ []) when is_atom(handler) do
    Connection.start_link(handler, opts)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) when is_pid(pid), do: Connection.stop(pid)
end


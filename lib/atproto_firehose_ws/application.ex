# Path: lib/atproto_firehose_ws/application.ex
defmodule AtprotoFirehoseWs.Application do
  use Application

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: AtprotoFirehoseWs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end


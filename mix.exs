# Path: mix.exs
defmodule AtprotoFirehoseWs.MixProject do
  use Mix.Project

  def project do
    [
      app: :atproto_firehose_ws,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AtprotoFirehoseWs.Application, []}
    ]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.4"},
      {:cbor, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:ex_unit_junit_formatter, "~> 3.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end


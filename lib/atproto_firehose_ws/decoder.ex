# Path: lib/atproto_firehose_ws/decoder.ex
defmodule AtprotoFirehoseWs.Decoder do
  def decode_cbor(<<>>), do: {:error, :empty}

  def decode_cbor(bin) when is_binary(bin) do
    case :cbor.decode(bin) do
      {:ok, term, <<>>} -> {:ok, term}
      {:ok, term, _rest} -> {:ok, term}
      {:error, reason} -> {:error, reason}
    end
  rescue
    e -> {:error, e}
  end
end


# Path: README.md

# atproto_firehose_ws

**What is this?**  
`atproto_firehose_ws` is a small Elixir library that helps you listen to the **ATProto Firehose**. Think of the Firehose like a giant river of messages that social networks (like Bluesky) send out. This library lets your program "catch" those messages in real time.

It is **atomic and composable**, meaning each module does one job and does it well, and you can combine them like building blocks.

---

## Why use this?

- If you want to track **everything happening on a server** (like posts, likes, and updates) without hitting the server repeatedly.
- If you want **unit-tested and CI-ready code** for Elixir projects.
- Works with **any storage or processing system**: Postgres, Kafka, or even custom pipelines.

---

## How it works

1. **Connection**  
   We open a WebSocket connection to a server (`wss://bsky.network/xrpc/com.atproto.sync.subscribeRepos`) to get a live feed.

2. **Backoff**  
   If the connection fails or the server says "slow down", we automatically wait longer each time, then try again. This is called **exponential backoff**.

3. **Event decoding**  
   Messages arrive in **CBOR** (a compact binary format). We decode them into Elixir maps so you can use them in your code.

4. **Handler callbacks**  
   Your program defines a **handler module** with these functions:

   ```elixir
   init(opts)             # called once when starting
   handle_event(event, s) # called every time a new message arrives
   handle_error(reason, s) # called if decoding or connection fails
Unit tests and CI
Tests are written using ExUnit. In CI (like GitLab), the tests produce JUnit XML reports, which can be read by human or AI tools (like Magistral).

Installation
Add this library to your mix.exs:

def deps do
  [
    {:atproto_firehose_ws, "~> 0.1.0"}
  ]
end
Then run:

mix deps.get
Example Usage
defmodule MyHandler do
  use AtprotoFirehoseWs.Handler

  @impl true
  def init(_opts), do: {:ok, %{}}

  @impl true
  def handle_event(event, state) do
    IO.inspect(event, label: "New ATProto Event")
    {:ok, state}
  end

  @impl true
  def handle_error(reason, state) do
    IO.puts("Error: #{inspect(reason)}")
    {:ok, state}
  end
end

{:ok, pid} = AtprotoFirehoseWs.start_link(MyHandler)
# later to stop
AtprotoFirehoseWs.stop(pid)
Testing
Run unit tests locally:

mix test
JUnit reports for CI are stored in:

test-results/
Integration tests can be tagged:

@tag :integration
And run manually:

INTEGRATION_TEST=true ./ci/run_ci.sh

How it’s organized
bash
Copy code
lib/atproto_firehose_ws/
├─ application.ex      # Starts the application
├─ backoff.ex          # Handles reconnection delays
├─ connection.ex       # WebSocket connection logic
├─ decoder.ex          # CBOR decoding
├─ event.ex            # Event struct
├─ handler.ex          # Callback behaviour
test/
├─ backoff_test.exs
├─ event_test.exs
├─ test_helper.exs
ci/
├─ run_ci.sh           # CI script
.gitlab-ci.yml         # GitLab CI configuration
mix.exs
README.md
Links to canonical documentation
ATProto Firehose: https://docs.bsky.app/docs/advanced-guides/firehose

ATProto Lexicon spec: https://atproto.com/specs/lexicon

ATProto Sync spec: https://atproto.com/specs/sync#firehose

Tips
Each module does one job only. You can combine them to build bigger systems.

You don’t have to store data inside this library. That is left to your application.

The library automatically handles rate limits and reconnects with backoff.


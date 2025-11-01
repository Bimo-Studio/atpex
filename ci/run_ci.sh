# Path: ci/run_ci.sh
#!/usr/bin/env bash
set -euo pipefail

# Basic CI script for Elixir project.
# Behaviors:
#  - uses MIX_ENV=test
#  - installs hex/rebar if missing
#  - fetches deps, compiles, runs tests
#  - optional checks: format, credo
#  - optionally runs integration tests if INTEGRATION_TEST=true

MIX_ENV=${MIX_ENV:-test}
INTEGRATION_TEST=${INTEGRATION_TEST:-false}
CI=${CI:-false}

echo "CI script starting (MIX_ENV=${MIX_ENV}, INTEGRATION_TEST=${INTEGRATION_TEST})"

# Make sure hex and rebar are present (idempotent)
mix local.hex --force
mix local.rebar --force

# fetch deps, compile
mix deps.get --only "$MIX_ENV"
mix deps.compile

# run formatting check (optional but useful)
echo "Checking code format..."
mix format --check-formatted

# static analysis / linting (optional)
if mix help credo >/dev/null 2>&1; then
  echo "Running credo..."
  mix credo --strict || true
else
  echo "credo not installed; skipping"
fi

# run tests
echo "Running unit tests with JUnit formatter..."
mix test --color --trace --slowest 10

# optionally run integration tests if requested
if [ "${INTEGRATION_TEST}" = "true" ] ; then
  echo "Running integration tests (INTEGRATION_TEST=true)"
  mix test --only integration
else
  echo "Skipping integration tests (set INTEGRATION_TEST=true to enable)"
fi

echo "CI script finished successfully."


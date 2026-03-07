#!/usr/bin/env bash
# Convenience script to run tests with proper environment setup

set -euo pipefail

# Ensure ~/.luarocks/bin is in PATH
export PATH="$HOME/.luarocks/bin:$PATH"

# Set LUABOTS_STUB_MQ to use the stub
export LUABOTS_STUB_MQ=1

# Check if busted is available
if ! command -v busted &> /dev/null; then
    echo "Error: busted is not installed or not in PATH"
    echo "Run ./scripts/install_deps.sh to install dependencies"
    exit 1
fi

# Run tests with any provided arguments
echo "Running tests..."
busted -v "$@"

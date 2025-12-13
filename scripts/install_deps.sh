#!/usr/bin/env bash
set -euo pipefail

# Install Lua 5.4, LuaRocks, and the busted test runner.
sudo apt-get update
sudo apt-get install -y lua5.4 luarocks
sudo luarocks install busted

echo "Add ~/.luarocks/bin to your PATH if it is not already present:"
echo "  export PATH=\"$HOME/.luarocks/bin:$PATH\""

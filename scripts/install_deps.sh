#!/usr/bin/env bash
set -euo pipefail

echo "Installing Lua 5.4, LuaRocks, and the busted test runner..."

# Install Lua 5.4, LuaRocks
sudo apt-get update
sudo apt-get install -y lua5.4 luarocks

# Install busted
echo "Installing busted..."
sudo luarocks install busted

# Check if ~/.luarocks/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.luarocks/bin:"* ]]; then
    echo ""
    echo "⚠️  Add ~/.luarocks/bin to your PATH:"
    echo "  export PATH=\"\$HOME/.luarocks/bin:\$PATH\""
    echo ""
    echo "Add this to your ~/.bashrc or ~/.zshrc to make it permanent."
else
    echo "✓ ~/.luarocks/bin is already in PATH"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "To run tests:"
echo "  busted -v spec                    # Run all tests"
echo "  busted -v spec/property_*.lua     # Run only property-based tests"
echo "  PROPERTY_SEED=12345 busted -v spec # Run with specific seed"


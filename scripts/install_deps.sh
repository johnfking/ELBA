#!/usr/bin/env bash
set -euo pipefail

echo "Installing LuaJIT, LuaRocks, and test dependencies..."

# Install LuaJIT and LuaRocks
sudo apt-get update
sudo apt-get install -y luajit luarocks

# Install busted and luacov
echo "Installing busted and luacov..."
sudo luarocks install busted
sudo luarocks install luacov

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
echo "  busted -v spec --coverage         # Run with coverage"
echo "  busted -v spec/property_*.lua     # Run only property-based tests"
echo "  PROPERTY_SEED=12345 busted -v spec # Run with specific seed"


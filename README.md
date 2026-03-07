# LuaBots - Emu Lua Bot API

LuaBots provides a Lua wrapper around the standard text chat-based Emu server-bot interface. It exposes a set of helper functions and enumerations for driving in‑game bots from Lua scripts. The project also includes lightweight stubs so the API can be unit tested without a running the MacroQuest environment.

## Repository layout

- `Bots.lua` – main `LuaBots` class with a wrapper for each bot command
- `Actionable.lua` – constructors for different bot selectors (single target, groups, heal rotations, etc.)
- `enums/` – enumerations used by the API (`Class`, `Gender`, `Race`, `Slot`, `SpellType`, `Stance`, `PetType`)
- `mq.lua` – loads the real `mq` library if available or falls back to the bundled stub
- `mq_stub.lua` – test stub implementing a minimal subset of the MQ API
- `events.lua` and `parser.lua` – placeholders for MacroQuest event handling
- `spec/` – `busted` test suite exercising the command wrappers

## Environment setup

The repository expects a Lua 5.4 toolchain with LuaRocks available.

### Linux/macOS (Debian/Ubuntu)

On a fresh Debian/Ubuntu container, run the helper script to install Lua, LuaRocks, and the `busted` test runner:

```bash
./scripts/install_deps.sh
```

LuaRocks installs user executables (including `busted`) under `~/.luarocks/bin`. Add it to your `PATH` if it is not already present:

```bash
export PATH="$HOME/.luarocks/bin:$PATH"
```

Add this to your `~/.bashrc` or `~/.zshrc` to make it permanent.

### Windows

On Windows, you can use the PowerShell installation script (requires [Chocolatey](https://chocolatey.org/)):

```powershell
.\scripts\install_deps.ps1
```

Alternatively, install manually:
1. Install Lua from [LuaForWindows](https://github.com/rjpcomputing/luaforwindows/releases)
2. Install LuaRocks from [luarocks.org](https://luarocks.org/)
3. Run: `luarocks install busted`

### Manual Installation

If you prefer to install manually:

```bash
# Install Lua 5.4 and LuaRocks using your package manager
# Then install busted:
luarocks install busted
```

### Working behind a proxy

The helper script uses `apt-get` and `luarocks` to download packages from the public internet. If your environment routes
traffic through a proxy, make sure the proxy allows access to the domains listed in [`AGENTS.md`](AGENTS.md) or temporarily
unset proxy-related variables (for example `http_proxy`, `https_proxy`, `HTTP_PROXY`, and `HTTPS_PROXY`) before running the
script. Otherwise package downloads may fail before the test runner can be installed.

## Running the tests

The tests use the [busted](https://olivinelabs.com/busted/) framework. Once dependencies are installed, run:

```bash
# Using the convenience script (recommended)
./run_tests.sh              # Linux/macOS
.\run_tests.ps1             # Windows

# Or run busted directly
busted -v spec
```

For detailed testing information, troubleshooting, and advanced usage, see [TESTING.md](TESTING.md).

### Running Property-Based Tests

The property-based testing framework has been integrated with busted. You can run tests in several ways:

```bash
# Run all tests (example-based and property-based)
busted -v spec

# Run only property-based tests
busted -v spec/property_*.lua

# Run specific property test file
busted -v spec/property_actionable_spec.lua
busted -v spec/property_commands_spec.lua
busted -v spec/property_enums_spec.lua
busted -v spec/property_mq_stub_spec.lua

# Run with specific seed for reproducibility
PROPERTY_SEED=12345 busted -v spec
```

The property-based tests run 100 iterations per property by default (configurable in each test). The full test suite should complete in approximately 10-15 seconds.

## Usage example

```lua
local LuaBots = require('LuaBots.init')

local Actionable = LuaBots.Actionable
local Class = LuaBots.Class
local SpellType = LuaBots.SpellType
local Stance = LuaBots.Stance

-- Command the currently targeted bot to switch stance
LuaBots:stance(Stance.PASSIVE, Actionable.target())

-- All Clerics cast their FAST_HEALS on the target
LuaBots:cast(SpellType.FAST_HEALS, Actionable.byclass(Class.CLERIC))
```

## Architecture overview

The `LuaBots` module exposes one method per bot command. Each method simply formats a command string and sends it through the MQ interface. Commands can optionally target specific bots using `Actionable` instances.

For unit testing, `mq.lua` loads `mq_stub.lua` unless the environment variable `LUABOTS_STUB_MQ` is unset. This allows the test suite to verify the formatted commands without requiring MQ to be present.

Upcoming modules such as `events.lua` and `parser.lua` demonstrate how MacroQuest events might be handled but currently contain only placeholders.

## EQEmu server integration

LuaBots mirrors the command handlers that live under `zone/bot_commands` in the [EQEmu server](https://github.com/EQEmu/Server) source tree. See [`docs/eqemu_integration.md`](docs/eqemu_integration.md) for a tour of how the Lua helpers map to the underlying C++ implementation and how actionable selectors line up with the server-side bot filters.


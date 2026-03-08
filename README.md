# LuaBots - Emu Lua Bot API

[![Run Tests](https://github.com/johnfking/ELBA/actions/workflows/test.yml/badge.svg)](https://github.com/johnfking/ELBA/actions/workflows/test.yml)
[![Lua](https://img.shields.io/badge/LuaJIT-2.1-blue.svg)](https://luajit.org/)
[![Tests](https://img.shields.io/badge/tests-558%20passing-brightgreen.svg)](https://github.com/johnfking/ELBA)
[![Property Tests](https://img.shields.io/badge/property%20tests-103-blue.svg)](https://github.com/johnfking/ELBA)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/johnfking/ELBA)

LuaBots provides a Lua wrapper around the standard text chat-based Emu server-bot interface. It exposes a set of helper functions and enumerations for driving in‑game bots from Lua scripts. 

The library features a **functional architecture** that separates pure logic from side effects, enabling comprehensive property-based testing and maintaining full backward compatibility. The project includes lightweight stubs so the API can be unit tested without running the MacroQuest environment.

## Repository layout

### Core Modules
- `init.lua` – main entry point with backward-compatible API
- `LuaBots/` – functional core modules:
  - `Actionable.lua` – constructors for different bot selectors (single target, groups, heal rotations, etc.)
  - `CommandBuilder.lua` – pure functions for building command strings
  - `CommandExecutor.lua` – side-effect wrapper for command execution
  - `HTTPClient.lua` – injectable HTTP client for bot creation
  - `NameGenerator.lua` – deterministic bot name generation with RNG state management
  - `mq.lua` – loads the real `mq` library if available or falls back to the bundled stub
  - `mq_stub.lua` – test stub implementing a minimal subset of the MQ API with capture mode
  - `events.lua` and `parser.lua` – placeholders for MacroQuest event handling
- `enums/` – enumerations used by the API (`Class`, `Gender`, `Race`, `Slot`, `SpellType`, `Stance`, `PetType`)

### Testing
- `spec/` – comprehensive test suite with 558 tests:
  - Unit tests for all modules
  - `spec/property/` – 103 property-based tests validating correctness properties
  - `spec/test_helpers.lua` – test utilities and state management
  - `spec/generators.lua` – property test data generators
  - `spec/property.lua` – property-based testing framework

### Documentation
- `docs/side-effects.md` – guide to the functional architecture and side-effect management
- `docs/eqemu_integration.md` – mapping to EQEmu server implementation
- `.kiro/specs/functional-refactoring/` – complete refactoring specification

## Environment setup

The repository expects LuaJIT 2.1 with LuaRocks available.

### Linux/macOS (Debian/Ubuntu)

On a fresh Debian/Ubuntu container, run the helper script to install LuaJIT, LuaRocks, and the `busted` test runner:

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
1. Install LuaJIT from [luajit.org](https://luajit.org/)
2. Install LuaRocks from [luarocks.org](https://luarocks.org/)
3. Run: `luarocks install busted` and `luarocks install luacov`

### Manual Installation

If you prefer to install manually:

```bash
# Install LuaJIT and LuaRocks using your package manager
# Then install test dependencies:
luarocks install busted
luarocks install luacov
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

# Run with coverage
busted -v spec --coverage
luacov                      # Generate coverage report
```

The test suite includes:
- **455 unit and integration tests** covering all modules
- **103 property-based tests** validating correctness properties:
  - Command builder purity and idempotence
  - Command string format consistency
  - HTTP injection and build-execute equivalence
  - Backward compatibility preservation
  - RNG state determinism and isolation
  - Output capture independence
  - Package configuration round-trip integrity

All 558 tests typically complete in 10-15 seconds with **100% code coverage** on all core modules.

For detailed testing information, troubleshooting, and advanced usage, see [docs/testing.md](docs/testing.md).

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

LuaBots uses a **functional architecture** that separates pure logic from side effects:

- **CommandBuilder** - Pure functions that build command strings with no side effects
- **CommandExecutor** - Thin wrapper that executes commands via the MQ interface
- **HTTPClient** - Injectable HTTP client for testable bot creation
- **NameGenerator** - Deterministic name generation with explicit RNG state management

The main `init.lua` module provides a backward-compatible API that delegates to these functional components. This architecture enables:

- **Comprehensive testing** - Pure functions can be tested exhaustively with property-based testing
- **Dependency injection** - HTTP and RNG dependencies can be swapped for testing
- **State isolation** - No global state or hidden side effects
- **Backward compatibility** - Existing code continues to work unchanged

For unit testing, `LuaBots/mq.lua` loads `LuaBots/mq_stub.lua` unless the environment variable `LUABOTS_STUB_MQ` is unset. The stub supports both normal and capture modes, allowing tests to verify formatted commands without requiring MQ to be present.

See [`docs/side-effects.md`](docs/side-effects.md) for a detailed guide to the functional architecture.

## EQEmu server integration

LuaBots mirrors the command handlers that live under `zone/bot_commands` in the [EQEmu server](https://github.com/EQEmu/Server) source tree. See [`docs/eqemu_integration.md`](docs/eqemu_integration.md) for a tour of how the Lua helpers map to the underlying C++ implementation and how actionable selectors line up with the server-side bot filters.

## Quality Assurance

This project uses **property-based testing** to validate correctness properties that must hold for all inputs:

- **Purity** - Command builders produce identical outputs for identical inputs with no side effects
- **Idempotence** - Repeated calls with the same inputs always produce the same results
- **Format consistency** - All commands follow the `/say ^<command> [params]` format
- **Backward compatibility** - Refactored code produces identical outputs to legacy implementation
- **State isolation** - RNG and output capture operations don't interfere with each other

Each property is tested across 100 randomly generated inputs, providing strong evidence of correctness. The test suite runs automatically on every push via GitHub Actions.


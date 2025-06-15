# ELBA - Emu Lua Bot API

ELBA provides a Lua wrapper around the standard chat-based Emu server-bot interface. It exposes a set of helper functions and enumerations for driving in‑game bots from Lua scripts. The project also includes lightweight stubs so the API can be unit tested without a running MacroQuest environment.

## Repository layout

- `Bots.lua` – main `Elba` class with a wrapper for each bot command
- `Actionable.lua` – constructors for different bot selectors (single target, groups, heal rotations, etc.)
- `enums/` – enumerations used by the API (`Class`, `Gender`, `Race`, `Slot`, `SpellType`, `Stance`, `PetType`)
- `mq.lua` – loads the real `mq` library if available or falls back to the bundled stub
- `mq_stub.lua` – test stub implementing a minimal subset of the MQ API
- `events.lua` and `parser.lua` – placeholders for MacroQuest event handling
- `spec/` – `busted` test suite exercising the command wrappers

## Running the tests

The tests use the [busted](https://olivinelabs.com/busted/) framework. Ensure dependencies are installed via LuaRocks and run:

```bash
busted -v spec
```

## Usage example

```lua
local Elba = require('Bots')

-- Command the currently targeted bot to switch stance
Elba:stance(Elba.Stance.PASSIVE, Elba.Actionable.target())
-- OR
Elba:stance(Elba.Stance.PASSIVE)
--  Emu Bots' Actionables default to current target; less obvious what is going on here.  Do not reccomend this pattern.

-- Cast a spell on all spawned bots
Elba:cast('Minor Healing', Elba.Actionable.spawned())
```

## Architecture overview

The `Elba` module exposes one method per bot command. Each method simply formats a command string and sends it through the MQ interface. Commands can optionally target specific bots using `Actionable` instances.

For unit testing, `mq.lua` loads `mq_stub.lua` unless the environment variable `ELBA_STUB_MQ` is unset. This allows the test suite to verify the formatted commands without requiring MQ to be present.

Upcoming modules such as `events.lua` and `parser.lua` demonstrate how MacroQuest events might be handled but currently contain only placeholders.


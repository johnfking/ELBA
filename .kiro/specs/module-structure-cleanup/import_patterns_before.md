# Import Patterns Before Migration

## Files with CORRECT imports (already using LuaBots. prefix)

### init.lua
- Line 29: `local mq = require('LuaBots.mq')` ✓
- Line 35: `LuaBots.Actionable = require('LuaBots.Actionable')` ✓
- Line 36-45: All enum imports use `LuaBots.enums.*` ✓
- Line 48-51: All module imports use `LuaBots.*` ✓

### LuaBots/CommandExecutor.lua
- Line 29: `local mq = require('LuaBots.mq')` ✓
- Line 41: `local mq = require('LuaBots.mq')` ✓

### mq.lua
- Line 10: `return require('LuaBots.mq_stub')` ✓

### examples/bot_setup_luabots.lua
- Line 12: `local mq = require('LuaBots.mq')` ✓
- Line 49: `local LuaBots = require('LuaBots.init')` ✓

## Files with INCORRECT imports (need updating)

### parser.lua
- Line 2: `local mq = require("elba.mq")` ❌
  - Should be: `require('LuaBots.mq')`

### events.lua
- Line 2: `local mq = require("elba.mq")` ❌
  - Should be: `require('LuaBots.mq')`
- Line 3: `local parser = require("elba.parser")` ❌
  - Should be: `require('LuaBots.parser')`

## Files with external dependencies (no changes needed)

### mq_stub.lua
- Line 6: `local socket = require('socket')` - external dependency ✓

### LuaBots/HTTPClient.lua
- Line 20: `local http = require('socket.http')` - external dependency ✓
- Line 21: `local ltn12 = require('ltn12')` - external dependency ✓

### LuaBots/NameGenerator.lua
- Line 49: `local json = require('cjson')` - external dependency ✓

### init.lua
- Line 71: `local PackageMan = require('mq.PackageMan')` - test infrastructure ✓

## Summary

**Problem**: The codebase is in an inconsistent state
- init.lua and CommandExecutor.lua already expect files in LuaBots/ directory
- But the actual files (mq.lua, mq_stub.lua, Actionable.lua, parser.lua, events.lua) are still in root
- parser.lua and events.lua still use old "elba.*" namespace

**Solution for Task 1**: 
We cannot establish a baseline with 558 passing tests because the code is already broken. The imports have been updated but the files haven't been moved yet. We need to either:
1. Move the files immediately to match the imports (Tasks 2-6)
2. Or temporarily revert the imports to match current file locations

Since the spec expects us to establish a baseline first, I'll document this state and report it to the user.

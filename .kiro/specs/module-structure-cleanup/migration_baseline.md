# Migration Baseline Documentation

## Date
Generated: $(date)

## Current File Locations

### Files in Root Directory (Need to Move)
1. `Actionable.lua` - 0 dependencies, used by init.lua
2. `mq.lua` - depends on mq_stub.lua, used by init.lua and other modules
3. `mq_stub.lua` - 0 dependencies, used by mq.lua
4. `events.lua` - depends on mq.lua and parser.lua
5. `parser.lua` - depends on mq.lua

### Files Already in LuaBots/ Directory
1. `LuaBots/CommandBuilder.lua`
2. `LuaBots/CommandExecutor.lua`
3. `LuaBots/HTTPClient.lua`
4. `LuaBots/NameGenerator.lua`

## Current Import Patterns

### init.lua (Line 29)
```lua
local mq = require('LuaBots.mq')  -- EXPECTS file in LuaBots/ but file is in root
```

### init.lua (Line 34)
```lua
LuaBots.Actionable = require('LuaBots.Actionable')  -- EXPECTS file in LuaBots/ but file is in root
```

## Test Suite Status

### Current State
- Tests are FAILING because init.lua expects files in LuaBots/ directory
- Error: `module 'LuaBots.mq' not found`
- Error: `module 'LuaBots.mq_stub' not found`

### Expected Baseline (After Task 1)
- 558 tests passing
- 0 failures
- 0 errors
- 100% code coverage

## Issue Identified

The codebase is in an **inconsistent state**:
- init.lua already uses `require('LuaBots.mq')` and `require('LuaBots.Actionable')`
- But mq.lua, mq_stub.lua, and Actionable.lua are still in the root directory
- This causes all tests to fail with "module not found" errors

## Resolution Strategy

Since the imports have already been updated to expect files in LuaBots/, we need to:
1. Move the files to LuaBots/ directory immediately to match the import expectations
2. Update any internal imports within those files
3. Run tests to establish the baseline

This is actually Task 2-6 work, but it's necessary to establish a working baseline.

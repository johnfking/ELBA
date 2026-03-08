# Side Effects Documentation Guide

## Table of Contents

1. [What Are Side Effects?](#what-are-side-effects)
2. [Why Side Effects Matter](#why-side-effects-matter)
3. [Pure Functions in LuaBots](#pure-functions-in-luabots)
4. [Functions with Side Effects](#functions-with-side-effects)
5. [Recommended Patterns for Handling Side Effects](#recommended-patterns-for-handling-side-effects)
6. [Testing Strategies](#testing-strategies)

---

## What Are Side Effects?

A **side effect** is any operation that modifies state outside its local scope or interacts with the external world. Common side effects include:

- **I/O Operations**: Reading from or writing to files, network, console, or other devices
- **State Mutation**: Modifying global variables, module-level state, or shared data structures
- **Network Calls**: Making HTTP requests or other network communications
- **Command Execution**: Sending commands to external systems (e.g., MacroQuest via `mq.cmd()`)

In contrast, a **pure function** is one that:
- Always returns the same output for the same input
- Has no side effects (doesn't modify external state or perform I/O)
- Is deterministic and predictable

---

## Why Side Effects Matter

Understanding and managing side effects is crucial for several reasons:

1. **Testability**: Pure functions are easy to test without mocks or complex setup
2. **Predictability**: Code without side effects is easier to reason about and debug
3. **Composability**: Pure functions can be safely combined and reused
4. **Maintainability**: Clear separation of concerns makes code easier to modify
5. **Reproducibility**: Pure functions produce consistent results, making bugs easier to reproduce

The LuaBots library has been refactored to separate pure logic (command construction) from side effects (command execution), making the codebase more testable and maintainable.

---

## Pure Functions in LuaBots


All pure functions in LuaBots are located in the **CommandBuilder** module (`LuaBots/CommandBuilder.lua`). These functions construct command strings without executing them or performing any side effects.

### CommandBuilder Module Functions

The CommandBuilder module provides pure functions for building bot command strings. All functions follow the same pattern:
- Accept command parameters (values, actionables)
- Return a command string ready for execution
- Do NOT call `mq.cmd()` or `mq.cmdf()`
- Do NOT modify global state
- Do NOT perform I/O operations

#### Complete List of Pure Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `build_stance(value, act)` | Build stance command string | Command string |
| `build_attack(value, act)` | Build attack command string | Command string |
| `build_guard(value, act)` | Build guard command string | Command string |
| `build_follow(value, act)` | Build follow command string | Command string |
| `build_botcreate(name, class, race, gender)` | Build botcreate command string | Command string |
| `build_applypoison(value, act)` | Build applypoison command string | Command string |
| `build_applypotion(value, act)` | Build applypotion command string | Command string |
| `build_behindmob(value, act)` | Build behindmob command string | Command string |
| `build_bindaffinity(value, act)` | Build bindaffinity command string | Command string |
| `build_blockedbuffs(value, act)` | Build blockedbuffs command string | Command string |
| `build_blockedpetbuffs(value, act)` | Build blockedpetbuffs command string | Command string |
| `build_botappearance(value, act)` | Build botappearance command string | Command string |
| `build_botbeardcolor(value, act)` | Build botbeardcolor command string | Command string |
| `build_botbeardstyle(value, act)` | Build botbeardstyle command string | Command string |
| `build_botcamp(value, act)` | Build botcamp command string | Command string |
| `build_botdelete(value, act)` | Build botdelete command string | Command string |
| `build_botdetails(value, act)` | Build botdetails command string | Command string |
| `build_botdyearmor(slot, r, g, b, act)` | Build botdyearmor command string | Command string |
| `build_boteyes(value, act)` | Build boteyes command string | Command string |
| `build_botface(value, act)` | Build botface command string | Command string |
| `build_botfollowdistance(value, act)` | Build botfollowdistance command string | Command string |
| `build_bothaircolor(value, act)` | Build bothaircolor command string | Command string |
| `build_bothairstyle(value, act)` | Build bothairstyle command string | Command string |
| `build_botheritage(value, act)` | Build botheritage command string | Command string |
| `build_botinspectmessage(value, act)` | Build botinspectmessage command string | Command string |
| `build_botlist(value, act)` | Build botlist command string | Command string |
| `build_botoutofcombat(value, act)` | Build botoutofcombat command string | Command string |
| `build_botreport(value, act)` | Build botreport command string | Command string |
| `build_botsettings(value, act)` | Build botsettings command string | Command string |
| `build_botspawn(value, act)` | Build botspawn command string | Command string |
| `build_botstance(value, act)` | Build botstance command string | Command string |
| `build_botstopmeleelevel(value, act)` | Build botstopmeleelevel command string | Command string |
| `build_botsuffix(value, act)` | Build botsuffix command string | Command string |
| `build_botsummon(value, act)` | Build botsummon command string | Command string |
| `build_botsurname(value, act)` | Build botsurname command string | Command string |
| `build_bottattoo(value, act)` | Build bottattoo command string | Command string |
| `build_bottitle(value, act)` | Build bottitle command string | Command string |
| `build_bottogglearcher(value, act)` | Build bottogglearcher command string | Command string |
| `build_bottogglehelm(value, act)` | Build bottogglehelm command string | Command string |
| `build_bottoggleranged(value, act)` | Build bottoggleranged command string | Command string |
| `build_botupdate(value, act)` | Build botupdate command string | Command string |
| `build_botwoad(value, act)` | Build botwoad command string | Command string |

| `build_cast(value, act)` | Build cast command string | Command string |
| `build_casterrange(value, act)` | Build casterrange command string | Command string |
| `build_charm(value, act)` | Build charm command string | Command string |
| `build_circle(value, act)` | Build circle command string | Command string |
| `build_classracelist(value, act)` | Build classracelist command string | Command string |
| `build_clickitem(value, act)` | Build clickitem command string | Command string |
| `build_copysettings(value, act)` | Build copysettings command string | Command string |
| `build_cure(value, act)` | Build cure command string | Command string |
| `build_defaultsettings(value, act)` | Build defaultsettings command string | Command string |
| `build_defensive(value, act)` | Build defensive command string | Command string |
| `build_depart(value, act)` | Build depart command string | Command string |
| `build_discipline(value, act)` | Build discipline command string | Command string |
| `build_distanceranged(value, act)` | Build distanceranged command string | Command string |
| `build_enforcespellsettings(value, act)` | Build enforcespellsettings command string | Command string |
| `build_escape(value, act)` | Build escape command string | Command string |
| `build_findaliases(value, act)` | Build findaliases command string | Command string |
| `build_pull(value, act)` | Build pull command string | Command string |
| `build_healrotation(value, act)` | Build healrotation command string | Command string |
| `build_healrotationadaptivetargeting(value, act)` | Build healrotationadaptivetargeting command string | Command string |
| `build_healrotationaddmember(value, act)` | Build healrotationaddmember command string | Command string |
| `build_healrotationaddtarget(value, act)` | Build healrotationaddtarget command string | Command string |
| `build_healrotationadjustcritical(value, act)` | Build healrotationadjustcritical command string | Command string |
| `build_healrotationadjustsafe(value, act)` | Build healrotationadjustsafe command string | Command string |
| `build_healrotationcastingoverride(value, act)` | Build healrotationcastingoverride command string | Command string |
| `build_healrotationchangeinterval(value, act)` | Build healrotationchangeinterval command string | Command string |
| `build_healrotationclearhot(value, act)` | Build healrotationclearhot command string | Command string |
| `build_healrotationcleartargets(value, act)` | Build healrotationcleartargets command string | Command string |
| `build_healrotationcreate(value, act)` | Build healrotationcreate command string | Command string |
| `build_healrotationdelete(value, act)` | Build healrotationdelete command string | Command string |
| `build_healrotationfastheals(value, act)` | Build healrotationfastheals command string | Command string |
| `build_healrotationlist(value, act)` | Build healrotationlist command string | Command string |
| `build_healrotationremovemember(value, act)` | Build healrotationremovemember command string | Command string |
| `build_healrotationremovetarget(value, act)` | Build healrotationremovetarget command string | Command string |
| `build_healrotationresetlimits(value, act)` | Build healrotationresetlimits command string | Command string |
| `build_healrotationsave(value, act)` | Build healrotationsave command string | Command string |
| `build_healrotationsethot(value, act)` | Build healrotationsethot command string | Command string |
| `build_healrotationstart(value, act)` | Build healrotationstart command string | Command string |
| `build_healrotationstop(value, act)` | Build healrotationstop command string | Command string |
| `build_help(value, act)` | Build help command string | Command string |
| `build_hold(value, act)` | Build hold command string | Command string |
| `build_identify(value, act)` | Build identify command string | Command string |
| `build_illusionblock(value, act)` | Build illusionblock command string | Command string |
| `build_inventory(value, act)` | Build inventory command string | Command string |
| `build_inventorygive(value, act)` | Build inventorygive command string | Command string |
| `build_inventorylist(value, act)` | Build inventorylist command string | Command string |
| `build_inventoryremove(value, act)` | Build inventoryremove command string | Command string |
| `build_inventorywindow(value, act)` | Build inventorywindow command string | Command string |
| `build_invisibility(value, act)` | Build invisibility command string | Command string |
| `build_itemuse(value, act)` | Build itemuse command string | Command string |

And many more... (100+ builder functions total)

### Example Usage of Pure Functions

```lua
local CommandBuilder = require('LuaBots.CommandBuilder')
local Actionable = require('LuaBots.Actionable')

-- Pure function call - no side effects
local cmd1 = CommandBuilder.build_stance("Passive")
-- Returns: "/say ^stance Passive"

-- Can call multiple times with same result
local cmd2 = CommandBuilder.build_stance("Passive")
assert(cmd1 == cmd2)  -- Always true (idempotent)

-- With actionable
local act = Actionable.byname("BotName")
local cmd3 = CommandBuilder.build_attack("on", act)
-- Returns: "/say ^attack on byname BotName"
```

---


## Functions with Side Effects

Functions with side effects are those that interact with the external world or modify state. In LuaBots, these are primarily the command execution functions and the initialization function.

### Side Effect Categories

#### 1. Command Execution (I/O Operations)

All LuaBots command functions execute bot commands via `mq.cmd()`, which is an I/O operation that sends commands to MacroQuest.

**Module**: `init.lua` (main LuaBots module)

**Side Effect Type**: I/O operation via `mq.cmd()`

**Complete List of Command Functions**:

| Function | Side Effect | Description |
|----------|-------------|-------------|
| `LuaBots:stance(value, act)` | Executes via mq.cmd() | Changes bot stance |
| `LuaBots:attack(value, act)` | Executes via mq.cmd() | Instructs bots to attack |
| `LuaBots:guard(value, act)` | Executes via mq.cmd() | Instructs bots to guard |
| `LuaBots:follow(value, act)` | Executes via mq.cmd() | Instructs bots to follow |
| `LuaBots:applypoison(value, act)` | Executes via mq.cmd() | Apply poison command |
| `LuaBots:applypotion(value, act)` | Executes via mq.cmd() | Apply potion command |
| `LuaBots:behindmob(value, act)` | Executes via mq.cmd() | Behind mob command |
| `LuaBots:bindaffinity(value, act)` | Executes via mq.cmd() | Bind affinity command |
| `LuaBots:blockedbuffs(value, act)` | Executes via mq.cmd() | Blocked buffs command |
| `LuaBots:blockedpetbuffs(value, act)` | Executes via mq.cmd() | Blocked pet buffs command |
| `LuaBots:botappearance(value, act)` | Executes via mq.cmd() | Bot appearance command |
| `LuaBots:botbeardcolor(value, act)` | Executes via mq.cmd() | Bot beard color command |
| `LuaBots:botbeardstyle(value, act)` | Executes via mq.cmd() | Bot beard style command |
| `LuaBots:botcamp(value, act)` | Executes via mq.cmd() | Bot camp command |
| `LuaBots:botdelete(value, act)` | Executes via mq.cmd() | Delete bot command |
| `LuaBots:botdetails(value, act)` | Executes via mq.cmd() | Bot details command |
| `LuaBots:botdyearmor(slot, r, g, b, act)` | Executes via mq.cmd() | Dye bot armor command |
| `LuaBots:boteyes(value, act)` | Executes via mq.cmd() | Bot eyes command |
| `LuaBots:botface(value, act)` | Executes via mq.cmd() | Bot face command |
| `LuaBots:botfollowdistance(value, act)` | Executes via mq.cmd() | Bot follow distance command |
| `LuaBots:bothaircolor(value, act)` | Executes via mq.cmd() | Bot hair color command |
| `LuaBots:bothairstyle(value, act)` | Executes via mq.cmd() | Bot hair style command |
| `LuaBots:botheritage(value, act)` | Executes via mq.cmd() | Bot heritage command |
| `LuaBots:botinspectmessage(value, act)` | Executes via mq.cmd() | Bot inspect message command |
| `LuaBots:botlist(value, act)` | Executes via mq.cmd() | List bots command |
| `LuaBots:botoutofcombat(value, act)` | Executes via mq.cmd() | Bot out of combat command |
| `LuaBots:botreport(value, act)` | Executes via mq.cmd() | Bot report command |
| `LuaBots:botsettings(value, act)` | Executes via mq.cmd() | Bot settings command |
| `LuaBots:botspawn(value, act)` | Executes via mq.cmd() | Spawn bot command |
| `LuaBots:botstance(value, act)` | Executes via mq.cmd() | Bot stance command |
| `LuaBots:botstopmeleelevel(value, act)` | Executes via mq.cmd() | Bot stop melee level command |
| `LuaBots:botsuffix(value, act)` | Executes via mq.cmd() | Bot suffix command |
| `LuaBots:botsummon(value, act)` | Executes via mq.cmd() | Summon bot command |
| `LuaBots:botsurname(value, act)` | Executes via mq.cmd() | Bot surname command |
| `LuaBots:bottattoo(value, act)` | Executes via mq.cmd() | Bot tattoo command |
| `LuaBots:bottitle(value, act)` | Executes via mq.cmd() | Bot title command |
| `LuaBots:bottogglearcher(value, act)` | Executes via mq.cmd() | Toggle archer command |
| `LuaBots:bottogglehelm(value, act)` | Executes via mq.cmd() | Toggle helm command |
| `LuaBots:bottoggleranged(value, act)` | Executes via mq.cmd() | Toggle ranged command |
| `LuaBots:botupdate(value, act)` | Executes via mq.cmd() | Update bot command |
| `LuaBots:botwoad(value, act)` | Executes via mq.cmd() | Bot woad command |
| `LuaBots:cast(value, act)` | Executes via mq.cmd() | Cast spell command |
| `LuaBots:casterrange(value, act)` | Executes via mq.cmd() | Caster range command |
| `LuaBots:charm(value, act)` | Executes via mq.cmd() | Charm command |
| `LuaBots:circle(value, act)` | Executes via mq.cmd() | Circle command |
| `LuaBots:classracelist(value, act)` | Executes via mq.cmd() | Class race list command |
| `LuaBots:clickitem(value, act)` | Executes via mq.cmd() | Click item command |
| `LuaBots:copysettings(value, act)` | Executes via mq.cmd() | Copy settings command |
| `LuaBots:cure(value, act)` | Executes via mq.cmd() | Cure command |

And 50+ more command functions... (all follow the same pattern)


#### 2. Special Case: botcreate with Network I/O

**Function**: `LuaBots:botcreate(name, class, race, gender, http_client)`

**Side Effects**:
- **HTTP request** for name generation when `name="AUTO"` (network I/O)
- **Executes bot command** via `mq.cmd()` (I/O operation)
- **Prints to stdout** (I/O operation)

**Description**: The `botcreate` function has additional side effects when the name parameter is set to "AUTO". It makes an HTTP request to an external API to generate a random name based on race and gender.

**Example**:
```lua
-- With auto-generated name (network I/O + command execution + stdout)
local bot = LuaBots:botcreate("AUTO", 1, 1, 0)

-- With explicit name (only command execution)
local bot = LuaBots:botcreate("MyBot", 1, 1, 0)

-- With custom HTTP client for testing (dependency injection)
local mock_client = HTTPClient.create_mock_http_client({
  ["https://names.ironarachne.com/race/human/male/1"] = {
    body = '{"names":["TestBot"]}',
    code = 200
  }
})
local bot = LuaBots:botcreate("AUTO", 1, 1, 0, mock_client)
```

#### 3. Module Initialization

**Function**: `LuaBots:initialize()`

**Side Effects**: Modifies module-level variables by loading external packages

**Description**: Loads HTTP and JSON dependencies into module-level variables. This is a one-time initialization that should be called before using `botcreate` with "AUTO" name generation.

**Example**:
```lua
local LuaBots = require('LuaBots')
LuaBots:initialize()  -- Load dependencies
```

#### 4. Command Executor Module

**Module**: `LuaBots/CommandExecutor.lua`

**Functions**:
- `CommandExecutor.execute(cmd)` - Executes command via `mq.cmd()`
- `CommandExecutor.executef(fmt, ...)` - Formats and executes command via `mq.cmdf()`

**Side Effect Type**: I/O operation (command execution)

**Description**: These functions are the low-level executors that perform the actual side effects. They are used internally by all LuaBots command functions.

**Example**:
```lua
local CommandExecutor = require('LuaBots.CommandExecutor')

-- Execute a pre-built command string
CommandExecutor.execute("/say ^stance Passive")

-- Execute with formatting
CommandExecutor.executef("/say ^stance %s", "Aggressive")
```

#### 5. Name Generator Module

**Module**: `LuaBots/NameGenerator.lua`

**Function**: `NameGenerator.generate_name(race, gender, http_client)`

**Side Effects**: HTTP request (network I/O)

**Description**: Makes an HTTP request to an external API to generate a bot name. Returns `nil, error_message` on failure.

**Example**:
```lua
local NameGenerator = require('LuaBots.NameGenerator')
local HTTPClient = require('LuaBots.HTTPClient')

local client = HTTPClient.create_default_http_client()
local name, err = NameGenerator.generate_name(1, 0, client)

if name then
  print("Generated name: " .. name)
else
  print("Error: " .. err)
end
```

---


## Recommended Patterns for Handling Side Effects

The LuaBots library has been refactored to follow functional programming principles that separate pure logic from side effects. Here are the recommended patterns:

### 1. Builder + Executor Pattern

**Pattern**: Separate command construction (pure) from command execution (side effect)

**Benefits**:
- Pure command builders can be tested without mocks
- Command strings can be inspected, logged, or modified before execution
- Easy to compose and reuse command logic

**Implementation**:

```lua
-- Pure function: builds command string
local CommandBuilder = require('LuaBots.CommandBuilder')
local cmd = CommandBuilder.build_stance("Passive")
-- cmd = "/say ^stance Passive"

-- Side effect: executes command
local CommandExecutor = require('LuaBots.CommandExecutor')
CommandExecutor.execute(cmd)
```

**Usage in LuaBots**:

All LuaBots command functions follow this pattern internally:

```lua
function LuaBots:stance(value, act)
    local cmd = CommandBuilder.build_stance(value, act)  -- Pure
    CommandExecutor.execute(cmd)                         -- Side effect
end
```

### 2. Dependency Injection

**Pattern**: Pass dependencies (HTTP clients, RNG state, output sinks) as parameters instead of using globals

**Benefits**:
- Functions become testable without modifying global state
- Easy to provide mock implementations for testing
- Explicit dependencies make code easier to understand

**Implementation**:

```lua
-- Production code: use default HTTP client
local bot = LuaBots:botcreate("AUTO", 1, 1, 0)

-- Test code: inject mock HTTP client
local mock_client = HTTPClient.create_mock_http_client({
  ["https://names.ironarachne.com/race/human/male/1"] = {
    body = '{"names":["TestBot"]}',
    code = 200
  }
})
local bot = LuaBots:botcreate("AUTO", 1, 1, 0, mock_client)
```

**Key Principle**: Optional parameters maintain backward compatibility while enabling testability.

### 3. Return Values Instead of Side Effects

**Pattern**: Return data structures instead of modifying global state

**Benefits**:
- Easier to test and verify
- More composable and reusable
- Explicit data flow

**Example**:

```lua
-- Good: Returns configuration data
local config = create_package_config()
-- config = { aliases = {...}, preload = {...}, loaded = {...} }

-- Then explicitly apply it
apply_package_config(config)

-- And restore when done
restore_package_config(backup)
```

### 4. Explicit State Management

**Pattern**: Pass state explicitly rather than modifying globals

**Benefits**:
- Reproducible test failures (can rerun with same seed)
- Isolated tests that don't interfere with each other
- Clear data flow

**Example**:

```lua
-- Create isolated state
local state = create_test_state(12345)  -- Explicit seed

-- Run test with state
state = property.forall(generators, test_fn, opts, state)

-- State contains final RNG seed for next test or reproduction
print("Final seed: " .. state.rng_seed)
```

### 5. Command Capture for Testing

**Pattern**: Capture commands instead of executing them during tests

**Benefits**:
- Tests don't trigger actual side effects
- Can verify exact commands that would be executed
- Fast and deterministic tests

**Implementation**:

```lua
-- Enable capture mode
local mq = require('spec.mq_stub')
mq.enable_capture()

-- Execute commands (captured, not executed)
LuaBots:stance("Passive")
LuaBots:attack("on")

-- Verify captured commands
local commands = mq.get_captured_commands()
assert.equals(2, #commands)
assert.equals("/say ^stance Passive", commands[1])
assert.equals("/say ^attack on", commands[2])

-- Clean up
mq.clear_captured_commands()
mq.disable_capture()
```

### 6. Output Redirection

**Pattern**: Redirect output to a sink instead of modifying `io.write`

**Benefits**:
- Tests can capture output without affecting other tests
- No global state modification
- Automatic cleanup via pcall

**Implementation**:

```lua
local capture = require('spec.capture')

-- Capture output from a function
local output = capture(function()
  print("Hello, world!")
  io.write("Test output")
end)

assert.equals("Hello, world!\nTest output", output)
```

### 7. Backward Compatibility

**Pattern**: Add optional parameters for new functionality while maintaining existing signatures

**Benefits**:
- Existing code continues to work without changes
- New code can opt into functional patterns
- Gradual migration path

**Implementation**:

```lua
-- Old code still works
LuaBots:botcreate("MyBot", 1, 1, 0)

-- New code can inject dependencies
LuaBots:botcreate("AUTO", 1, 1, 0, custom_http_client)
```

---


## Testing Strategies

Testing code with side effects requires different strategies than testing pure functions. Here's how to approach testing in LuaBots:

### Testing Pure Functions

Pure functions are the easiest to test because they have no side effects.

**Strategy**: Direct assertion testing

**Example**:

```lua
describe("CommandBuilder", function()
  local CommandBuilder = require('LuaBots.CommandBuilder')
  
  it("should build stance command with value", function()
    local cmd = CommandBuilder.build_stance("Passive")
    assert.equals("/say ^stance Passive", cmd)
  end)
  
  it("should be idempotent", function()
    local cmd1 = CommandBuilder.build_stance("Aggressive")
    local cmd2 = CommandBuilder.build_stance("Aggressive")
    assert.equals(cmd1, cmd2)
  end)
  
  it("should handle nil values", function()
    local cmd = CommandBuilder.build_stance(nil)
    assert.equals("/say ^stance", cmd)
  end)
end)
```

### Testing Functions with I/O Side Effects

Functions that perform I/O need special handling to avoid actual side effects during tests.

**Strategy 1: Command Capture**

Use the mq_stub's capture mode to intercept commands:

```lua
describe("LuaBots commands", function()
  local LuaBots = require('LuaBots')
  local mq = require('spec.mq_stub')
  
  before_each(function()
    mq.enable_capture()
    mq.clear_captured_commands()
  end)
  
  after_each(function()
    mq.disable_capture()
  end)
  
  it("should execute stance command", function()
    LuaBots:stance("Passive")
    
    local commands = mq.get_captured_commands()
    assert.equals(1, #commands)
    assert.equals("/say ^stance Passive", commands[1])
  end)
end)
```

**Strategy 2: Verify Builder + Executor Interaction**

Test that the high-level function correctly uses the builder and executor:

```lua
describe("LuaBots:stance", function()
  it("should use CommandBuilder and CommandExecutor", function()
    local builder_called = false
    local executor_called = false
    local captured_cmd = nil
    
    -- Spy on builder
    local original_build = CommandBuilder.build_stance
    CommandBuilder.build_stance = function(value, act)
      builder_called = true
      return original_build(value, act)
    end
    
    -- Spy on executor
    local original_execute = CommandExecutor.execute
    CommandExecutor.execute = function(cmd)
      executor_called = true
      captured_cmd = cmd
    end
    
    -- Execute
    LuaBots:stance("Passive")
    
    -- Verify
    assert.is_true(builder_called)
    assert.is_true(executor_called)
    assert.equals("/say ^stance Passive", captured_cmd)
    
    -- Restore
    CommandBuilder.build_stance = original_build
    CommandExecutor.execute = original_execute
  end)
end)
```

### Testing Functions with Network Side Effects

Functions that make HTTP requests need mock HTTP clients.

**Strategy**: Dependency Injection with Mock Client

```lua
describe("LuaBots:botcreate with AUTO name", function()
  local LuaBots = require('LuaBots')
  local HTTPClient = require('LuaBots.HTTPClient')
  local mq = require('spec.mq_stub')
  
  before_each(function()
    mq.enable_capture()
    mq.clear_captured_commands()
  end)
  
  after_each(function()
    mq.disable_capture()
  end)
  
  it("should generate name via HTTP and create bot", function()
    -- Create mock HTTP client
    local mock_client = HTTPClient.create_mock_http_client({
      ["https://names.ironarachne.com/race/human/male/1"] = {
        body = '{"names":["GeneratedName"]}',
        code = 200
      }
    })
    
    -- Create bot with AUTO name
    local bot = LuaBots:botcreate("AUTO", 1, 1, 0, mock_client)
    
    -- Verify bot info
    assert.is_not_nil(bot)
    assert.equals("GeneratedName", bot.Name)
    assert.equals(1, bot.Class)
    
    -- Verify command was executed
    local commands = mq.get_captured_commands()
    assert.equals(1, #commands)
    assert.matches("^/say %^botcreate GeneratedName", commands[1])
  end)
  
  it("should handle HTTP failure gracefully", function()
    -- Create mock client that returns error
    local mock_client = HTTPClient.create_mock_http_client({
      ["https://names.ironarachne.com/race/human/male/1"] = {
        body = "",
        code = 500
      }
    })
    
    -- Attempt to create bot
    local bot = LuaBots:botcreate("AUTO", 1, 1, 0, mock_client)
    
    -- Should return nil on failure
    assert.is_nil(bot)
  end)
end)
```

### Property-Based Testing

Property-based tests verify universal properties across many inputs.

**Strategy**: Use property testing framework with explicit state

```lua
describe("CommandBuilder properties", function()
  local property = require('spec.property')
  local CommandBuilder = require('LuaBots.CommandBuilder')
  
  it("should always return strings", function()
    property.forall(
      {
        property.string(1, 20),  -- Random value
        property.oneof({'target', 'spawned', 'all'})  -- Random actionable
      },
      function(value, act_type)
        local Actionable = require('LuaBots.Actionable')
        local act = Actionable[act_type]()
        
        local cmd = CommandBuilder.build_stance(value, act)
        
        assert.is_string(cmd)
        assert.matches("^/say %^stance", cmd)
      end,
      { iterations = 100 }
    )
  end)
  
  it("should be idempotent", function()
    property.forall(
      { property.string(1, 20) },
      function(value)
        local cmd1 = CommandBuilder.build_stance(value)
        local cmd2 = CommandBuilder.build_stance(value)
        
        assert.equals(cmd1, cmd2)
      end,
      { iterations = 100 }
    )
  end)
end)
```

### Testing State Management

Test that state is properly isolated and managed.

**Strategy**: Verify state isolation and round-trip properties

```lua
describe("Property test state management", function()
  local property = require('spec.property')
  
  it("should create isolated state for each test", function()
    local state1 = property.create_test_state(12345)
    local state2 = property.create_test_state(12345)
    
    -- Run tests with each state
    property.forall({property.integer(1, 100)}, function(x) end, {}, state1)
    property.forall({property.integer(1, 100)}, function(x) end, {}, state2)
    
    -- States should have diverged (different final seeds)
    assert.is_not_equal(state1.rng_seed, state2.rng_seed)
  end)
end)
```

### Running Tests

Use the `busted` test framework to run all tests:

```bash
# Run all tests
busted -v spec

# Run specific test file
busted -v spec/command_builder_spec.lua

# Run with coverage
busted -v --coverage spec
```

### Test Organization

Organize tests by module and type:

```
spec/
  unit/                          # Unit tests for specific functions
    command_builder_spec.lua
    command_executor_spec.lua
    name_generator_spec.lua
  
  property/                      # Property-based tests
    property_builder_purity_spec.lua
    property_backward_compat_spec.lua
  
  integration/                   # Integration tests
    luabots_integration_spec.lua
  
  helpers/                       # Test helpers
    LuaBots/mq_stub.lua
    capture.lua
    package_config.lua
```

---

## Summary

The LuaBots library demonstrates a functional programming approach to managing side effects:

1. **Pure Functions** (CommandBuilder) construct commands without side effects
2. **Side Effect Functions** (LuaBots commands, CommandExecutor) perform I/O operations
3. **Dependency Injection** enables testing without mocks (HTTP client, RNG state)
4. **Builder + Executor Pattern** separates logic from effects
5. **Command Capture** allows testing without triggering actual side effects
6. **Backward Compatibility** maintained through optional parameters

By following these patterns, the codebase becomes more testable, maintainable, and easier to reason about. Pure functions can be tested directly, while functions with side effects use dependency injection and capture mechanisms for safe testing.

For more details on the refactoring design, see `.kiro/specs/functional-refactoring/design.md`.


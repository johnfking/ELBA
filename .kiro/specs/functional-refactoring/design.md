# Design Document: Functional Refactoring

## Overview

This design refactors the LuaBots library to separate pure logic from side effects, making the codebase more testable, maintainable, and easier to reason about. The current implementation tightly couples command construction with execution (via `mq.cmd()`), modifies global state (RNG seeds, package tables, io.write), and performs I/O operations within core logic functions.

The refactoring introduces a command builder pattern that separates command construction from execution, externalizes state management, and provides dependency injection for I/O operations. This approach maintains backward compatibility while enabling pure functional testing and better composability.

### Key Design Principles

1. **Separation of Concerns**: Pure command builders construct command strings; separate executor functions perform side effects
2. **Dependency Injection**: External dependencies (HTTP client, RNG state, output sinks) are passed as parameters
3. **Backward Compatibility**: Existing API signatures remain unchanged; new optional parameters enable functional patterns
4. **Explicit State Management**: State is passed explicitly rather than modified globally
5. **Testability**: Pure functions can be tested without mocks; side effects are isolated and controllable

## Architecture

### Current Architecture

```
┌─────────────────────────────────────┐
│   LuaBots Command Functions         │
│  (stance, attack, botcreate, etc.)  │
│                                      │
│  • Construct command string          │
│  • Immediately call mq.cmd()         │
│  • Perform HTTP requests             │
│  • Return void or simple values      │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   mq.cmd() / mq.cmdf()              │
│   (Side Effect: Execute command)     │
└─────────────────────────────────────┘
```

### Refactored Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  LuaBots Public API                       │
│                                                           │
│  Backward-compatible command functions                    │
│  (stance, attack, botcreate with optional params)        │
└──────────────────────────────────────────────────────────┘
         │
         ├─────────────────────┬─────────────────────┐
         ▼                     ▼                     ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  Command         │  │  Command         │  │  Side Effect     │
│  Builders        │  │  Executor        │  │  Dependencies    │
│  (Pure)          │  │                  │  │                  │
│                  │  │  execute(cmd)    │  │  • HTTP client   │
│  build_stance()  │  │  ├─> mq.cmd()   │  │  • RNG state     │
│  build_attack()  │  │                  │  │  • Output sink   │
│  build_create()  │  │                  │  │                  │
│  ...             │  │                  │  │                  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

### Component Layers

1. **Public API Layer**: Maintains existing function signatures, delegates to builders and executor
2. **Command Builder Layer**: Pure functions that construct command strings from parameters
3. **Executor Layer**: Handles side effects (mq.cmd calls, I/O operations)
4. **Dependency Layer**: Injectable dependencies (HTTP client, RNG state, output sinks)

## Components and Interfaces

### 1. Command Builder Module

Pure functions that construct command strings without side effects.

```lua
---@class CommandBuilder
local CommandBuilder = {}

--- Build a stance command string
---@param value any? stance value
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_stance(value, act)
  local parts = { '/say ^stance' }
  if value ~= nil then table.insert(parts, tostring(value)) end
  if act ~= nil then table.insert(parts, tostring(act)) end
  return table.concat(parts, ' ')
end

--- Build an attack command string
---@param value any? attack parameter
---@param act Actionable? actionable target
---@return string command string ready for execution
function CommandBuilder.build_attack(value, act)
  local parts = { '/say ^attack' }
  if value ~= nil then table.insert(parts, tostring(value)) end
  if act ~= nil then table.insert(parts, tostring(act)) end
  return table.concat(parts, ' ')
end

--- Build a botcreate command string
---@param name string bot name
---@param class number class ID
---@param race number race ID
---@param gender number gender ID
---@return string command string ready for execution
function CommandBuilder.build_botcreate(name, class, race, gender)
  return string.format("/say ^botcreate %s %d %d %d", name, class, race, gender)
end

-- Additional builder functions for all commands...
```

### 2. Command Executor Module

Handles side effects by executing command strings.

```lua
---@class CommandExecutor
local CommandExecutor = {}

--- Execute a command string using mq.cmd
---@param cmd string command to execute
function CommandExecutor.execute(cmd)
  mq.cmd(cmd)
end

--- Execute a formatted command string
---@param fmt string format string
---@param ... any format arguments
function CommandExecutor.executef(fmt, ...)
  mq.cmdf(fmt, ...)
end
```

### 3. HTTP Client Interface

Dependency injection for HTTP requests in botcreate.

```lua
---@class HTTPClient
---@field request fun(opts: table): string, number

--- Default HTTP client using luasocket
---@return HTTPClient
local function create_default_http_client()
  local http = require('socket.http')
  local ltn12 = require('ltn12')
  
  return {
    request = function(opts)
      local response = {}
      local _, code = http.request{
        url = opts.url,
        sink = ltn12.sink.table(response)
      }
      return table.concat(response), code
    end
  }
end

--- Mock HTTP client for testing
---@param responses table<string, {body: string, code: number}>
---@return HTTPClient
local function create_mock_http_client(responses)
  return {
    request = function(opts)
      local response = responses[opts.url] or { body = '{"names":["TestBot"]}', code = 200 }
      return response.body, response.code
    end
  }
end
```

### 4. Name Generator Module

Separates name generation logic from command execution.

```lua
---@class NameGenerator
local NameGenerator = {}

--- Generate a bot name using HTTP API
---@param race number race ID
---@param gender number gender ID
---@param http_client HTTPClient HTTP client for making requests
---@return string|nil name generated name or nil on failure
---@return string|nil error error message if failed
function NameGenerator.generate_name(race, gender, http_client)
  local race_map = {
    [1] = "human", [2] = "human", [3] = "human",
    [4] = "elf", [5] = "elf", [6] = "elf",
    [7] = "half-elf", [8] = "dwarf", [9] = "troll",
    [10] = "orc", [11] = "halfling", [12] = "gnome",
    [128] = "dragonborn", [130] = "tiefling",
    [330] = "goblin", [522] = "dragonborn"
  }
  
  local gender_map = { [0] = "male", [1] = "female" }
  
  local api_race = race_map[race] or "human"
  local api_gender = gender_map[gender] or "male"
  local url = string.format("https://names.ironarachne.com/race/%s/%s/1", api_race, api_gender)
  
  local body, code = http_client.request({ url = url })
  
  if code ~= 200 then
    return nil, string.format("HTTP request failed with code %d", code or 0)
  end
  
  local json = require('cjson')
  local data = json.decode(body)
  local names = data["names"]
  
  if type(names) == "table" and #names > 0 then
    return names[1], nil
  else
    return nil, "No valid names in API response"
  end
end
```

### 5. Refactored LuaBots Module

Updated to use builders and support dependency injection while maintaining backward compatibility.

```lua
---@class LuaBots
local LuaBots = {}

-- Internal references to builder and executor
local CommandBuilder = require('LuaBots.CommandBuilder')
local CommandExecutor = require('LuaBots.CommandExecutor')
local NameGenerator = require('LuaBots.NameGenerator')

--- Execute a stance command
---@param value any? stance value
---@param act Actionable? actionable target
function LuaBots:stance(value, act)
  local cmd = CommandBuilder.build_stance(value, act)
  CommandExecutor.execute(cmd)
end

--- Execute an attack command
---@param value any? attack parameter
---@param act Actionable? actionable target
function LuaBots:attack(value, act)
  local cmd = CommandBuilder.build_attack(value, act)
  CommandExecutor.execute(cmd)
end

--- Create a bot with optional HTTP client injection
---@param name string bot name or "AUTO" for generated name
---@param class number class ID
---@param race number race ID
---@param gender number gender ID
---@param http_client HTTPClient? optional HTTP client (for testing)
---@return table|nil bot_info bot information or nil on failure
function LuaBots:botcreate(name, class, race, gender, http_client)
  -- Use default HTTP client if not provided (backward compatibility)
  http_client = http_client or create_default_http_client()
  
  if name == "AUTO" then
    local generated_name, err = NameGenerator.generate_name(race, gender, http_client)
    if not generated_name then
      print(string.format("[LuaBots] Name generation failed: %s", err))
      return nil
    end
    name = generated_name
    print(string.format("[LuaBots] Auto-generated bot name: %s", name))
  end
  
  local cmd = CommandBuilder.build_botcreate(name, class, race, gender)
  CommandExecutor.execute(cmd)
  
  return { Name = name, Class = class, Race = race, Gender = gender }
end

-- Additional command functions follow same pattern...
```

### 6. Property Test Framework Refactoring

Externalize RNG state management for reproducibility.

```lua
---@class PropertyTestState
---@field rng_seed number current RNG seed
---@field iteration number current iteration count

--- Create a new property test state
---@param seed number? optional seed (defaults to os.time())
---@return PropertyTestState
local function create_test_state(seed)
  seed = seed or tonumber(os.getenv('PROPERTY_SEED')) or os.time()
  return {
    rng_seed = seed,
    iteration = 0
  }
end

--- Run a property test with explicit state management
---@param generators table list of generators
---@param test_fn function test function
---@param opts table? optional configuration
---@param state PropertyTestState? optional state (creates new if nil)
---@return PropertyTestState final state after test execution
function property.forall(generators, test_fn, opts, state)
  assert(type(generators) == 'table', 'generators must be a table')
  assert(type(test_fn) == 'function', 'test_fn must be a function')
  
  -- Create isolated state if not provided
  state = state or create_test_state()
  
  -- Set RNG seed for this test run
  math.randomseed(state.rng_seed)
  
  opts = opts or {}
  local iterations = opts.iterations or 100
  
  for i = 1, iterations do
    state.iteration = i
    
    -- Generate values from each generator
    local values = {}
    for j, gen in ipairs(generators) do
      assert(type(gen) == 'table' and type(gen.generate) == 'function',
        'generator ' .. j .. ' must have a generate function')
      values[j] = gen.generate()
    end
    
    -- Run the test function with generated values
    local success, err = pcall(test_fn, table.unpack(values))
    
    if not success then
      -- Report the failing input with seed for reproduction
      local input_str = {}
      for j, val in ipairs(values) do
        input_str[j] = string.format('%q', tostring(val))
      end
      
      error(string.format(
        'Property failed on iteration %d (seed: %d) with inputs: [%s]\nError: %s',
        i,
        state.rng_seed,
        table.concat(input_str, ', '),
        tostring(err)
      ), 2)
    end
  end
  
  -- Update state with final RNG state
  state.rng_seed = math.random(1, 2^31 - 1)
  
  return state
end
```

### 7. Test Helper Refactoring

Capture output without modifying global io.write.

```lua
---@class OutputSink
---@field write fun(self: OutputSink, text: string)
---@field get_output fun(self: OutputSink): string

--- Create an output sink that captures to a buffer
---@return OutputSink
local function create_buffer_sink()
  local buffer = {}
  
  return {
    write = function(self, text)
      table.insert(buffer, text)
    end,
    
    get_output = function(self)
      return table.concat(buffer)
    end
  }
end

--- Capture output from a function using a custom sink
---@param fn function function to execute
---@param sink OutputSink? optional sink (creates buffer sink if nil)
---@return string captured output
local function capture(fn, sink)
  sink = sink or create_buffer_sink()
  
  -- Save original io.write
  local original_write = io.write
  
  -- Temporarily replace io.write
  io.write = function(text)
    sink:write(text)
  end
  
  -- Execute function
  local success, err = pcall(fn)
  
  -- Restore original io.write
  io.write = original_write
  
  if not success then
    error(err, 2)
  end
  
  return sink:get_output()
end
```

### 8. mq_stub Command Capture

Add command capture mode for testing.

```lua
---@class MQStub
local M = {}

-- Command capture state
local capture_mode = false
local command_buffer = {}

--- Enable command capture mode
function M.enable_capture()
  capture_mode = true
  command_buffer = {}
end

--- Disable command capture mode
function M.disable_capture()
  capture_mode = false
end

--- Get captured commands
---@return table list of captured command strings
function M.get_captured_commands()
  return command_buffer
end

--- Clear command buffer
function M.clear_captured_commands()
  command_buffer = {}
end

--- Send a command string
---@param cmd string command to execute
function M.cmd(cmd)
  if capture_mode then
    table.insert(command_buffer, cmd)
  else
    io.write(cmd .. '\n')
  end
end

--- Format and send command
---@param fmt string format string
---@param ... any format arguments
function M.cmdf(fmt, ...)
  if select('#', ...) == 0 then
    M.cmd(fmt)
  else
    local msg = string.format(fmt, ...)
    M.cmd(msg)
  end
end
```

### 9. Package Setup Refactoring

Return configuration data instead of modifying globals.

```lua
---@class PackageConfig
---@field aliases table<string, string> package alias mappings
---@field preload table<string, function> package preload functions
---@field loaded table<string, any> loaded package cache

--- Create package configuration for LuaBots testing
---@return PackageConfig
local function create_package_config()
  return {
    aliases = {
      ['LuaBots.Actionable'] = 'Actionable',
      ['LuaBots.enums.Class'] = 'enums.Class',
      ['LuaBots.enums.Race'] = 'enums.Race',
      -- ... other aliases
    },
    preload = {},
    loaded = {}
  }
end

--- Apply package configuration to global package tables
---@param config PackageConfig configuration to apply
---@return PackageConfig backup of original state
local function apply_package_config(config)
  local backup = {
    aliases = {},
    preload = {},
    loaded = {}
  }
  
  -- Backup and apply aliases
  for alias, path in pairs(config.aliases) do
    backup.preload[alias] = package.preload[alias]
    package.preload[alias] = function()
      return require(path)
    end
  end
  
  return backup
end

--- Restore package configuration
---@param backup PackageConfig backup configuration to restore
local function restore_package_config(backup)
  for alias, loader in pairs(backup.preload) do
    package.preload[alias] = loader
  end
end
```

## Data Models

### Command String

A command string is a formatted string ready for execution by mq.cmd(). Format:

```
/say ^<command> [value1] [value2] [actionable]
```

Examples:
- `/say ^stance Passive`
- `/say ^attack on byname BotName`
- `/say ^botcreate MyBot 1 1 0`

### PropertyTestState

```lua
{
  rng_seed = number,    -- Current RNG seed for reproducibility
  iteration = number    -- Current iteration count
}
```

### PackageConfig

```lua
{
  aliases = {           -- Package alias mappings
    [alias] = path
  },
  preload = {           -- Package preload functions
    [name] = function
  },
  loaded = {            -- Loaded package cache
    [name] = module
  }
}
```

### HTTPClient Interface

```lua
{
  request = function(opts)
    -- opts: { url = string }
    -- returns: body (string), code (number)
  end
}
```

### OutputSink Interface

```lua
{
  write = function(self, text)
    -- Append text to sink
  end,
  
  get_output = function(self)
    -- Returns: accumulated output (string)
  end
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Command Builder Purity

*For any* command builder function and any valid input parameters, calling the builder should return a command string without performing any I/O operations, modifying global state, or calling mq.cmd/mq.cmdf.

**Validates: Requirements 1.1, 8.3, 8.4**

### Property 2: Command Builder Idempotence

*For any* command builder function and any input parameters, calling the builder multiple times with the same inputs should return identical command strings.

**Validates: Requirements 8.2**

### Property 3: Command String Format

*For any* command builder function and valid input parameters, the returned command string should match the format `/say ^<command> [params]` where params are properly formatted and ordered.

**Validates: Requirements 1.2**

### Property 4: Build-Execute Equivalence (Backward Compatibility)

*For any* command function and valid parameters, constructing a command using the builder and executing it should produce the same mq.cmd call as the original implementation.

**Validates: Requirements 1.4, 7.2**

### Property 5: RNG State Determinism

*For any* given RNG state and set of generators, calling property.forall() with that state should produce the same sequence of generated values across multiple runs.

**Validates: Requirements 2.2**

### Property 6: RNG State Isolation

*For any* sequence of property.forall() calls without explicit state sharing, each call should create isolated state that doesn't affect other tests.

**Validates: Requirements 2.3, 9.1, 9.2**

### Property 7: Output Capture Isolation

*For any* function that produces output, capturing its output using the capture helper should redirect all output to the provided sink and not to stdout.

**Validates: Requirements 3.2**

### Property 8: Output Capture Restoration

*For any* capture operation, after capture completes, io.write should be restored to its original value (round-trip property).

**Validates: Requirements 3.3**

### Property 9: Concurrent Capture Independence

*For any* set of concurrent capture operations, each capture should maintain its own buffer without interference from other captures.

**Validates: Requirements 3.4**

### Property 10: Package Configuration Round-Trip

*For any* package configuration, applying the configuration and then restoring the backup should return package.preload and package.loaded to their original state.

**Validates: Requirements 4.3**

### Property 11: Package Setup Purity

*For any* call to package setup functions (create_package_config), the function should return configuration data without modifying package.preload or package.loaded.

**Validates: Requirements 4.4**

### Property 12: HTTP Client Injection

*For any* custom HTTP client provided to botcreate with name="AUTO", the function should call that client's request method and use the returned name.

**Validates: Requirements 5.2**

### Property 13: Optional Parameter Backward Compatibility

*For any* LuaBots function with new optional parameters, calling the function without those parameters should work identically to the original implementation.

**Validates: Requirements 7.3**

### Property 14: Command Capture Accumulation

*For any* sequence of mq.cmd() calls in capture mode, all commands should be appended to the buffer in order.

**Validates: Requirements 10.2**

### Property 15: Property Test Confluence

*For any* set of independent property tests, running them in different orders should produce consistent results for each individual test.

**Validates: Requirements 9.4**

## Error Handling

### Command Builder Errors

Command builders should validate inputs and provide clear error messages:

1. **Invalid Actionable**: If an actionable requires a selector but none is provided, throw an error with message: `"Actionable type '<type>' requires a selector"`

2. **Invalid Parameters**: If required parameters are nil or wrong type, throw an error with message: `"Invalid parameter: expected <type>, got <actual>"`

3. **Format Errors**: If string formatting fails, propagate the error with context about which command failed

### Name Generation Errors

Name generation should handle failures gracefully:

1. **HTTP Failure**: If HTTP request fails, return `nil, error_message` instead of throwing
2. **JSON Parse Failure**: If response parsing fails, return `nil, "Failed to parse API response"`
3. **Empty Response**: If API returns no names, return `nil, "No valid names in API response"`
4. **Fallback**: Calling code should handle nil returns and either retry, use a default name, or abort

### Property Test Errors

Property tests should provide detailed failure information:

1. **Generator Failure**: If a generator fails, report which generator (by index) and the error
2. **Test Failure**: Report iteration number, RNG seed (for reproduction), generated inputs, and the actual error
3. **Format**: `"Property failed on iteration <N> (seed: <seed>) with inputs: [<values>]\nError: <error>"`

### Capture Errors

Capture operations should handle errors safely:

1. **Function Error**: If the captured function throws, restore io.write before propagating the error
2. **Sink Error**: If sink.write() fails, restore io.write and propagate the error
3. **Cleanup Guarantee**: Use pcall to ensure io.write is always restored, even on error

### Package Configuration Errors

Package operations should validate and handle errors:

1. **Invalid Config**: If configuration structure is invalid, throw error: `"Invalid package configuration: <reason>"`
2. **Missing Module**: If a required module doesn't exist, throw error: `"Module not found: <name>"`
3. **Restore Failure**: If restore fails, log warning but don't throw (best-effort restoration)

## Testing Strategy

### Dual Testing Approach

This refactoring requires both unit tests and property-based tests:

**Unit Tests** focus on:
- Specific examples of command building (e.g., `build_stance("Passive")` returns expected string)
- Edge cases (empty parameters, nil values, special characters)
- API existence (functions exist and have correct signatures)
- Integration points (executor calls mq.cmd, HTTP client is called)
- Error conditions (invalid actionables, missing parameters)

**Property-Based Tests** focus on:
- Universal properties across all inputs (purity, idempotence, format correctness)
- Round-trip properties (build-execute equivalence, capture restoration, package config round-trip)
- Isolation properties (RNG state, output capture, test independence)
- Backward compatibility across all command types
- Confluence (test order independence)

### Property-Based Testing Configuration

**Framework**: Use the refactored property testing framework in `spec/property.lua`

**Configuration**:
- Minimum 100 iterations per property test
- Explicit RNG seed from environment variable `PROPERTY_SEED` or os.time()
- Each test tagged with: `Feature: functional-refactoring, Property <N>: <description>`

**Generators**:
- Command parameters: strings (1-20 chars, alphanumeric), numbers (1-100), booleans
- Actionables: random selection from all actionable types with appropriate selectors
- RNG seeds: integers (1 to 2^31-1)
- HTTP responses: random JSON structures with names arrays

### Test Organization

```
spec/
  unit/
    command_builder_spec.lua      -- Unit tests for command builders
    name_generator_spec.lua        -- Unit tests for name generation
    capture_helper_spec.lua        -- Unit tests for output capture
    package_config_spec.lua        -- Unit tests for package setup
    mq_stub_capture_spec.lua       -- Unit tests for command capture
  
  property/
    property_builder_purity_spec.lua       -- Properties 1, 2, 3
    property_backward_compat_spec.lua      -- Properties 4, 13
    property_rng_isolation_spec.lua        -- Properties 5, 6
    property_capture_isolation_spec.lua    -- Properties 7, 8, 9
    property_package_config_spec.lua       -- Properties 10, 11
    property_http_injection_spec.lua       -- Property 12
    property_command_capture_spec.lua      -- Property 14
    property_test_confluence_spec.lua      -- Property 15
```

### Example Property Test

```lua
-- Feature: functional-refactoring, Property 1: Command Builder Purity
describe("Command Builder Purity", function()
  it("should not perform I/O or modify global state", function()
    local property = require('spec.property')
    local CommandBuilder = require('LuaBots.CommandBuilder')
    
    -- Track global state before test
    local original_io_write = io.write
    local mq_cmd_called = false
    
    -- Mock mq to detect calls
    package.loaded['mq'] = {
      cmd = function() mq_cmd_called = true end,
      cmdf = function() mq_cmd_called = true end
    }
    
    property.forall(
      {
        property.string(1, 20),  -- command value
        property.oneof({'target', 'spawned', 'all'})  -- actionable type
      },
      function(value, act_type)
        local Actionable = require('LuaBots.Actionable')
        local act = Actionable[act_type]()
        
        -- Call builder
        local cmd = CommandBuilder.build_stance(value, act)
        
        -- Verify no side effects
        assert.is_string(cmd)
        assert.is_false(mq_cmd_called, "Builder should not call mq.cmd")
        assert.equals(original_io_write, io.write, "Builder should not modify io.write")
      end,
      { iterations = 100 }
    )
  end)
end)
```

### Backward Compatibility Testing

All existing tests in the test suite must pass without modification. This validates that the refactoring maintains the same external behavior.

**Validation Process**:
1. Run existing test suite before refactoring (establish baseline)
2. Perform refactoring
3. Run existing test suite again (should pass without changes)
4. Add new property tests for refactored functionality
5. Add unit tests for new APIs (builders, injection points)

### Manual Testing

Some aspects require manual verification:
- Documentation completeness (Requirement 6)
- Performance characteristics (ensure refactoring doesn't degrade performance)
- Integration with actual MacroQuest environment (test with real mq module)
- HTTP name generation with real API (test network resilience)


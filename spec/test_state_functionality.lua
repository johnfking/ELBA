#!/usr/bin/env lua
--
-- Quick test to verify property.forall() state parameter functionality
--

local property = require('spec.property')

print("Testing property.forall() state parameter functionality...")

-- Test 1: Create a state and pass it to property.forall()
print("\n1. Testing state parameter acceptance...")
local initial_state = property.create_test_state(12345)
print("   Initial state: seed=" .. initial_state.rng_seed .. ", iteration=" .. initial_state.iteration)

local final_state = property.forall(
  { property.integer(1, 10) },
  function(val)
    assert(val >= 1 and val <= 10, "Value out of range")
  end,
  { iterations = 5 },
  initial_state
)

print("   Final state: seed=" .. final_state.rng_seed .. ", iteration=" .. final_state.iteration)
assert(final_state ~= nil, "property.forall() should return state")
assert(type(final_state) == 'table', "Returned state should be a table")
assert(final_state.rng_seed ~= nil, "Returned state should have rng_seed")
assert(final_state.iteration == 5, "Iteration should be 5 after 5 iterations")
print("   ✓ State parameter accepted and returned")

-- Test 2: Verify state is created when not provided
print("\n2. Testing automatic state creation...")
local auto_state = property.forall(
  { property.integer(1, 10) },
  function(val)
    assert(val >= 1 and val <= 10, "Value out of range")
  end,
  { iterations = 3 }
)

assert(auto_state ~= nil, "property.forall() should return state even when not provided")
assert(type(auto_state) == 'table', "Auto-created state should be a table")
assert(auto_state.rng_seed ~= nil, "Auto-created state should have rng_seed")
assert(auto_state.iteration == 3, "Iteration should be 3 after 3 iterations")
print("   ✓ State automatically created when not provided")

-- Test 3: Verify RNG seed is used for generation
print("\n3. Testing RNG seed determinism...")
local seed = 99999
local state1 = property.create_test_state(seed)
local values1 = {}

property.forall(
  { property.integer(1, 100) },
  function(val)
    table.insert(values1, val)
  end,
  { iterations = 5 },
  state1
)

-- Reset with same seed
local state2 = property.create_test_state(seed)
local values2 = {}

property.forall(
  { property.integer(1, 100) },
  function(val)
    table.insert(values2, val)
  end,
  { iterations = 5 },
  state2
)

-- Compare values
local all_match = true
for i = 1, #values1 do
  if values1[i] ~= values2[i] then
    all_match = false
    break
  end
end

assert(all_match, "Same seed should produce same values")
print("   Generated values (run 1): " .. table.concat(values1, ", "))
print("   Generated values (run 2): " .. table.concat(values2, ", "))
print("   ✓ Same seed produces deterministic values")

-- Test 4: Verify state.rng_seed is updated after execution
print("\n4. Testing RNG seed update...")
local before_seed = 55555
local test_state = property.create_test_state(before_seed)
assert(test_state.rng_seed == before_seed, "Initial seed should match")

local after_state = property.forall(
  { property.integer(1, 10) },
  function(val) end,
  { iterations = 1 },
  test_state
)

assert(after_state.rng_seed ~= before_seed, "RNG seed should be updated after execution")
print("   Before seed: " .. before_seed)
print("   After seed: " .. after_state.rng_seed)
print("   ✓ RNG seed updated after test execution")

print("\n✅ All tests passed! Task 6.2 is complete.")

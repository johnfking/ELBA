#!/usr/bin/env lua
-- Verification script to check test files load correctly

print("=== LuaBots Test Verification ===\n")

local function test_load(name, path)
    io.write(string.format("%-40s ... ", name))
    local ok, result = pcall(require, path)
    if ok then
        print("✓ OK")
        return true
    else
        print("✗ FAILED")
        print("  Error: " .. tostring(result))
        return false
    end
end

local all_ok = true

-- Test core modules
print("Core Modules:")
all_ok = test_load("Actionable", "LuaBots.Actionable") and all_ok
all_ok = test_load("MQ Stub", "mq_stub") and all_ok

-- Test enums
print("\nEnum Modules:")
all_ok = test_load("Class", "enums.Class") and all_ok
all_ok = test_load("Race", "enums.Race") and all_ok
all_ok = test_load("Gender", "enums.Gender") and all_ok
all_ok = test_load("SpellType", "enums.SpellType") and all_ok
all_ok = test_load("Stance", "enums.Stance") and all_ok
all_ok = test_load("MaterialSlot", "enums.MaterialSlot") and all_ok
all_ok = test_load("PetType", "enums.PetType") and all_ok
all_ok = test_load("Slot", "enums.Slot") and all_ok

-- Test property framework
print("\nProperty-Based Testing Framework:")
all_ok = test_load("Property Framework", "spec.property") and all_ok
all_ok = test_load("Test Generators", "spec.generators") and all_ok

-- Test that property framework works
print("\nProperty Framework Functionality:")
io.write("Testing integer generator              ... ")
local property = require('spec.property')
local gen = property.integer(1, 10)
local val = gen.generate()
if type(val) == 'number' and val >= 1 and val <= 10 then
    print("✓ OK (generated: " .. val .. ")")
else
    print("✗ FAILED")
    all_ok = false
end

io.write("Testing string generator               ... ")
local gen = property.string(5, 10)
local val = gen.generate()
if type(val) == 'string' and #val >= 5 and #val <= 10 then
    print("✓ OK (generated: '" .. val .. "')")
else
    print("✗ FAILED")
    all_ok = false
end

io.write("Testing boolean generator              ... ")
local gen = property.boolean()
local val = gen.generate()
if type(val) == 'boolean' then
    print("✓ OK (generated: " .. tostring(val) .. ")")
else
    print("✗ FAILED")
    all_ok = false
end

io.write("Testing oneof generator                ... ")
local gen = property.oneof({'a', 'b', 'c'})
local val = gen.generate()
if val == 'a' or val == 'b' or val == 'c' then
    print("✓ OK (generated: '" .. val .. "')")
else
    print("✗ FAILED")
    all_ok = false
end

-- Test generators
print("\nDomain-Specific Generators:")
local generators = require('spec.generators')

io.write("Testing class_value generator          ... ")
local gen = generators.class_value()
local val = gen.generate()
if val ~= nil then
    print("✓ OK (generated: " .. tostring(val) .. ")")
else
    print("✗ FAILED")
    all_ok = false
end

io.write("Testing actionable generator           ... ")
local gen = generators.any_actionable()
local val = gen.generate()
if val ~= nil and type(val) == 'table' then
    print("✓ OK (type: " .. val.type .. ")")
else
    print("✗ FAILED")
    all_ok = false
end

-- Test property.forall
print("\nProperty Test Runner:")
io.write("Testing property.forall                ... ")
local test_passed = true
local iterations = 0
property.forall(
    { property.integer(1, 100) },
    function(n)
        iterations = iterations + 1
        assert(n >= 1 and n <= 100, "Value out of range")
    end,
    { iterations = 10 }
)
if iterations == 10 then
    print("✓ OK (ran 10 iterations)")
else
    print("✗ FAILED (ran " .. iterations .. " iterations)")
    all_ok = false
end

-- Summary
print("\n" .. string.rep("=", 50))
if all_ok then
    print("✓ All verification checks passed!")
    print("\nThe property-based testing framework is ready.")
    print("Run 'busted -v spec' to execute the full test suite.")
    os.exit(0)
else
    print("✗ Some verification checks failed.")
    print("\nPlease check the errors above.")
    os.exit(1)
end

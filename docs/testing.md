# Testing Guide

This document provides detailed information about testing in the LuaBots project.

## Quick Start

```bash
# Linux/macOS
./run_tests.sh

# Windows
.\run_tests.ps1
```

## Test Structure

The project uses two complementary testing approaches:

### Example-Based Tests
Located in `spec/init_spec.lua` and `spec/bot_setup_luabots_spec.lua`, these tests verify specific examples and known scenarios.

### Property-Based Tests
Located in `spec/property_*.lua`, these tests verify universal properties across many randomly generated inputs:

- **spec/property_actionable_spec.lua** - Tests Actionable selector system (8 properties)
- **spec/property_commands_spec.lua** - Tests command formatting (12 properties)
- **spec/property_enums_spec.lua** - Tests enum integration (1 property covering 8 enum types)
- **spec/property_mq_stub_spec.lua** - Tests MQ stub behavior (5 properties)

## Property-Based Testing Framework

The property-based testing framework is implemented in:
- **spec/property.lua** - Core framework with generators and test runner
- **spec/generators.lua** - Domain-specific test data generators

### How It Works

Property-based tests verify that certain properties hold true across many random inputs:

```lua
property.forall(
  { generators.class_value() },
  function(class_value)
    -- This property should hold for ALL class values
    assert.is_true(tostring(class_value):len() > 0)
  end,
  { iterations = 100 }
)
```

Each property test runs 100 iterations by default, testing the property with different random inputs each time.

## Running Tests

### Run All Tests
```bash
busted -v spec
```

### Run Only Property-Based Tests
```bash
busted -v spec/property_*.lua
```

### Run Specific Test File
```bash
busted -v spec/property_actionable_spec.lua
```

### Run with Reproducible Seed
```bash
PROPERTY_SEED=12345 busted -v spec
```

This ensures the same random values are generated each time, useful for debugging failing tests.

## Troubleshooting

### "busted: command not found"

**Solution**: Install busted and ensure it's in your PATH:

```bash
# Linux/macOS
luarocks install busted
export PATH="$HOME/.luarocks/bin:$PATH"

# Windows
luarocks install busted
# Restart your terminal
```

### "module 'mq' not found"

**Solution**: The tests use a stub for the MQ library. Ensure `LUABOTS_STUB_MQ=1` is set:

```bash
export LUABOTS_STUB_MQ=1  # Linux/macOS
$env:LUABOTS_STUB_MQ = "1"  # Windows PowerShell
```

The convenience scripts (`run_tests.sh` / `run_tests.ps1`) set this automatically.

### Property Test Failures

When a property test fails, it will show:
1. The property that failed
2. The iteration number
3. The exact input values that caused the failure

Example:
```
Property failed on iteration 42 with inputs: ["byname", "TestBot123"]
Error: assertion failed
```

You can reproduce this failure by running with the same seed:
```bash
PROPERTY_SEED=<seed_from_output> busted -v spec/property_actionable_spec.lua
```

### Tests Run Slowly

Property-based tests run 100 iterations per property by default. To run faster during development:

1. Reduce iterations in specific tests (edit the `iterations` parameter)
2. Run only the test file you're working on
3. Use `busted spec/init_spec.lua` to run only example-based tests

## Test Coverage

The test suite provides comprehensive coverage:

- **26 correctness properties** verified
- **~2,600 test executions** per full run (26 properties × 100 iterations)
- **All major components** tested: Actionable system, command formatting, enums, MQ stub

## Continuous Integration

Tests run automatically on GitHub Actions for:
- Push to main/master/develop branches
- Pull requests

See `.github/workflows/test.yml` for the CI configuration.

## Writing New Tests

### Adding Example-Based Tests

Add to `spec/init_spec.lua`:

```lua
it('should do something specific', function()
  local result = LuaBots:someCommand()
  assert.equals(expected, result)
end)
```

### Adding Property-Based Tests

Add to the appropriate `spec/property_*.lua` file:

```lua
it('Property N: description', function()
  -- Feature: comprehensive-property-based-testing, Property N
  property.forall(
    { generators.some_generator() },
    function(value)
      -- Assert property holds for this value
      assert.is_true(some_condition(value))
    end,
    { iterations = 100 }
  )
end)
```

## Resources

- [Busted Documentation](https://olivinelabs.com/busted/)
- [Property-Based Testing Introduction](https://hypothesis.works/articles/what-is-property-based-testing/)
- [LuaRocks](https://luarocks.org/)

# Design Document: Module Structure Cleanup

## Overview

This design addresses the reorganization of the LuaBots module structure to follow Lua best practices and conventions. Currently, the repository has a hybrid structure with source files scattered between the root directory and the LuaBots/ subdirectory, requiring package.path hacks and package aliases in test files. This design provides a safe, incremental approach to consolidate all source files (except init.lua) into the LuaBots/ directory while maintaining 100% backward compatibility.

The refactoring will:
- Move 5 source files from root to LuaBots/ subdirectory
- Standardize all imports to use the LuaBots. prefix consistently
- Remove package.path modifications and package aliases from test files
- Preserve all 558 tests with 100% coverage
- Maintain complete backward compatibility for external users

### Key Design Principles

1. **Backward Compatibility First**: External users must not need to change their code
2. **Incremental Migration**: Move files one at a time with validation at each step
3. **Test-Driven Validation**: Run full test suite after each file move
4. **Standard Lua Conventions**: Follow established patterns for module organization

## Architecture

### Current Structure

```
LuaBots/
├── init.lua                    (root - main module entry point)
├── Actionable.lua              (root - needs to move)
├── mq.lua                      (root - needs to move)
├── mq_stub.lua                 (root - needs to move)
├── events.lua                  (root - needs to move)
├── parser.lua                  (root - needs to move)
├── LuaBots/
│   ├── CommandBuilder.lua      (already in correct location)
│   ├── CommandExecutor.lua     (already in correct location)
│   ├── HTTPClient.lua          (already in correct location)
│   └── NameGenerator.lua       (already in correct location)
├── enums/                      (already in correct location)
└── spec/                       (test files with package hacks)
```

### Target Structure

```
LuaBots/
├── init.lua                    (root - stays here)
├── LuaBots/
│   ├── Actionable.lua          (moved from root)
│   ├── mq.lua                  (moved from root)
│   ├── mq_stub.lua             (moved from root)
│   ├── events.lua              (moved from root)
│   ├── parser.lua              (moved from root)
│   ├── CommandBuilder.lua      (already here)
│   ├── CommandExecutor.lua     (already here)
│   ├── HTTPClient.lua          (already here)
│   └── NameGenerator.lua       (already here)
├── enums/                      (unchanged)
└── spec/                       (tests updated to use standard imports)
```

### Module Resolution Strategy

Lua's module system searches for modules using `package.path`. The standard pattern for a module named `LuaBots.Actionable` is:

1. Look for `LuaBots/Actionable.lua` relative to the current directory
2. Look for `LuaBots/Actionable/init.lua` as an alternative

By placing all source files in `LuaBots/`, we align with Lua conventions and eliminate the need for custom package.path modifications.

### Import Standardization

All imports will use the fully qualified module name with the `LuaBots.` prefix:

**Before:**
```lua
-- Inconsistent patterns
local Actionable = require('Actionable')           -- root-relative
local mq = require('elba.mq')                      -- old namespace
local CommandBuilder = require('LuaBots.CommandBuilder')  -- correct
```

**After:**
```lua
-- Consistent pattern
local Actionable = require('LuaBots.Actionable')
local mq = require('LuaBots.mq')
local CommandBuilder = require('LuaBots.CommandBuilder')
```

## Components and Interfaces

### Files to Relocate

#### 1. Actionable.lua
- **Current Location**: `./Actionable.lua`
- **Target Location**: `LuaBots/Actionable.lua`
- **Dependencies**: None (self-contained)
- **Dependents**: init.lua, test files
- **Import Updates Required**: 
  - init.lua: Already uses `require('LuaBots.Actionable')`
  - Test files: Need to remove package aliases

#### 2. mq.lua
- **Current Location**: `./mq.lua`
- **Target Location**: `LuaBots/mq.lua`
- **Dependencies**: `LuaBots.mq_stub` (conditional)
- **Dependents**: init.lua, CommandExecutor.lua, events.lua, parser.lua
- **Import Updates Required**:
  - mq.lua itself: Update `require('LuaBots.mq_stub')` (already correct)
  - init.lua: Update to `require('LuaBots.mq')`
  - CommandExecutor.lua: Already uses `require('LuaBots.mq')`
  - events.lua: Update from `require('elba.mq')` to `require('LuaBots.mq')`
  - parser.lua: Update from `require('elba.mq')` to `require('LuaBots.mq')`

#### 3. mq_stub.lua
- **Current Location**: `./mq_stub.lua`
- **Target Location**: `LuaBots/mq_stub.lua`
- **Dependencies**: None
- **Dependents**: mq.lua (conditional require)
- **Import Updates Required**: None (loaded via mq.lua)

#### 4. events.lua
- **Current Location**: `./events.lua`
- **Target Location**: `LuaBots/events.lua`
- **Dependencies**: `LuaBots.mq`, `LuaBots.parser`
- **Dependents**: None currently (future integration point)
- **Import Updates Required**:
  - events.lua: Update imports from `elba.*` to `LuaBots.*`

#### 5. parser.lua
- **Current Location**: `./parser.lua`
- **Target Location**: `LuaBots/parser.lua`
- **Dependencies**: `LuaBots.mq`
- **Dependents**: events.lua
- **Import Updates Required**:
  - parser.lua: Update import from `elba.mq` to `LuaBots.mq`

### Test File Updates

Test files currently use two problematic patterns:

1. **Package Path Modifications**:
```lua
package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path
```

2. **Package Aliases**:
```lua
local function setup_package_aliases()
  local function alias(name, target)
    package.preload[name] = function() return require(target) end
  end
  alias('LuaBots.Actionable', 'Actionable')
  -- ... more aliases
end
```

Both patterns will be removed. Tests will use standard imports:
```lua
local Actionable = require('LuaBots.Actionable')
local CommandBuilder = require('LuaBots.CommandBuilder')
```

The only exception is `mq.PackageMan`, which is test infrastructure and should remain in `package.preload`.

### Backward Compatibility Mechanism

The init.lua file already exposes modules correctly:

```lua
-- This pattern maintains backward compatibility
LuaBots.Actionable = require('LuaBots.Actionable')
LuaBots.Class = require('LuaBots.enums.Class')
-- etc.
```

External users can access modules via:
- `require('LuaBots')` - returns the main module
- `LuaBots.Actionable` - accesses the Actionable module
- `LuaBots:stance()` - calls command functions

This interface remains unchanged regardless of internal file locations.

## Data Models

### File Migration Record

For tracking and validation during migration:

```lua
---@class FileMigration
---@field source_path string Original file path (e.g., "Actionable.lua")
---@field target_path string New file path (e.g., "LuaBots/Actionable.lua")
---@field dependencies string[] List of modules this file imports
---@field dependents string[] List of files that import this module
---@field import_updates table<string, string> Map of files to their required import changes
---@field status "pending"|"in_progress"|"completed"|"validated" Migration status
```

### Import Pattern

```lua
---@class ImportPattern
---@field old_pattern string Pattern to search for (e.g., "require%(\'elba%.mq\'%)")
---@field new_pattern string Replacement pattern (e.g., "require('LuaBots.mq')")
---@field file_path string File containing the import
---@field line_number number Line number of the import
```

### Test Configuration

```lua
---@class TestConfig
---@field remove_package_path boolean Whether to remove package.path modification
---@field remove_aliases string[] List of package aliases to remove
---@field keep_preload string[] List of package.preload entries to keep (e.g., "mq.PackageMan")
---@field standard_imports string[] List of standard imports to use
```

## Migration Sequence

The migration follows this order to minimize dependency issues:

1. **mq_stub.lua** - No dependencies, only used by mq.lua
2. **mq.lua** - Depends on mq_stub.lua (already moved)
3. **parser.lua** - Depends on mq.lua (already moved)
4. **events.lua** - Depends on mq.lua and parser.lua (both already moved)
5. **Actionable.lua** - No dependencies, widely used but imports are already correct in init.lua

After each file move:
1. Update all imports in the moved file
2. Update all imports in dependent files
3. Run full test suite (`busted -v spec`)
4. Verify 558 tests pass with 0 failures
5. Verify 100% code coverage maintained

## Error Handling

### Module Resolution Errors

If a module cannot be found after migration:

```lua
-- Error message format
"module 'LuaBots.Actionable' not found:
  no file 'LuaBots/Actionable.lua'
  no file 'LuaBots/Actionable/init.lua'"
```

**Prevention**:
- Verify file exists at target location before updating imports
- Use `package.loaded` to check if module is already loaded
- Test module resolution with `pcall(require, 'LuaBots.ModuleName')`

### Import Update Errors

If an import is missed during migration:

```lua
-- Old import still present
local mq = require('elba.mq')  -- Will fail after migration
```

**Detection**:
- Search for old import patterns: `require%(\'elba%.`, `require%(\'Actionable\'%)`
- Run tests after each file move
- Use static analysis to find all require() calls

### Test Failure Scenarios

1. **Module Not Found**: File moved but import not updated
   - **Recovery**: Update the import to use new path
   
2. **Package Alias Conflict**: Old alias interferes with new import
   - **Recovery**: Remove the alias from test setup
   
3. **Circular Dependency**: Import order creates circular reference
   - **Recovery**: Restructure imports or use lazy loading

### Rollback Strategy

If migration fails at any step:

1. **Immediate Rollback**: Move file back to original location
2. **Revert Import Changes**: Restore original require() statements
3. **Verify Tests**: Run test suite to confirm rollback success
4. **Document Issue**: Record what failed and why

Each file migration is atomic - either fully complete or fully rolled back.

## Testing Strategy

### Dual Testing Approach

The testing strategy combines unit tests and property-based tests:

- **Unit Tests**: Verify specific migration steps, edge cases, and error conditions
- **Property Tests**: Verify universal properties hold across all migration scenarios

### Unit Testing Focus

Unit tests will verify:

1. **File Operations**:
   - File successfully moved to new location
   - Original file removed from old location
   - File contents unchanged after move

2. **Import Updates**:
   - All require() statements updated correctly
   - No old import patterns remain
   - Module resolution works from all contexts

3. **Test File Cleanup**:
   - package.path modifications removed
   - Package aliases removed (except mq.PackageMan)
   - Standard imports work correctly

4. **Backward Compatibility**:
   - External API unchanged
   - All 558 existing tests pass
   - Module exports match original structure

5. **Edge Cases**:
   - Empty files handle correctly
   - Files with no imports
   - Files with circular dependencies
   - Test files with complex setup

### Property-Based Testing

Property tests will use the `busted` framework with custom property test helpers. Each test will run a minimum of 100 iterations.

**Property Test Configuration**:
- Library: Custom property testing framework (spec/property.lua)
- Iterations: 100 minimum per property
- Tag Format: `-- Feature: module-structure-cleanup, Property {N}: {description}`

Properties will be tested using generators that create:
- Random file paths
- Random import patterns
- Random module names
- Random test configurations

### Test Execution

```bash
# Run all tests
busted -v spec

# Expected output
558 successes / 0 failures / 0 errors / 0 pending : 0.123456 seconds

# Verify coverage
luacov
cat luacov.report.out | grep "^Summary"
# Expected: 100% coverage
```

### Validation Checklist

After migration completes:

- [ ] All 558 tests pass
- [ ] Zero test failures
- [ ] Zero test errors
- [ ] 100% code coverage maintained
- [ ] No package.path modifications in test files
- [ ] No package aliases (except mq.PackageMan)
- [ ] All imports use LuaBots. prefix
- [ ] No files remain in root except init.lua
- [ ] Module resolution works from all contexts
- [ ] Backward compatibility verified


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified several areas of redundancy:

1. **File location checks (1.2-1.6)** can be combined into a single property about all moved files
2. **Import pattern checks (2.1-2.6)** are specific examples of the general property 2.7
3. **Test file import checks (3.4-3.5)** are specific examples of the general property 3.3
4. **Module resolution checks (7.2-7.4)** are specific examples that will be covered by the test suite passing
5. **Backward compatibility checks (4.2-4.5)** are all covered by the general property 4.6

The properties below represent the unique, non-redundant validation requirements.

### Property 1: File relocation completeness

*For all* source files in the migration list (Actionable.lua, mq.lua, mq_stub.lua, events.lua, parser.lua), after migration each file should exist in LuaBots/ directory and not exist in the root directory.

**Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6, 1.7**

### Property 2: Import prefix consistency

*For all* require() statements in source files that reference LuaBots modules, the import path should start with 'LuaBots.' prefix.

**Validates: Requirements 2.7, 8.2**

### Property 3: Test files use standard imports

*For all* test files in the spec/ directory, all require() statements for LuaBots modules should use the 'LuaBots.' prefix without package.path modifications or package aliases (except mq.PackageMan).

**Validates: Requirements 3.1, 3.2, 3.3**

### Property 4: No relative path imports

*For all* require() statements in the codebase, none should use relative path patterns like '../' or './' for LuaBots modules.

**Validates: Requirements 8.1**

### Property 5: No package alias functions

*For all* test files, none should contain setup_package_aliases() or similar functions that create package.preload entries for source modules.

**Validates: Requirements 8.3, 8.4**

### Property 6: Module resolution succeeds

*For all* LuaBots modules, require('LuaBots.ModuleName') should successfully load the module without errors.

**Validates: Requirements 7.1, 7.5**

### Property 7: Backward compatibility preservation

*For all* public API functions and properties exposed by the LuaBots module, the behavior and interface should remain identical after reorganization (verified by all existing tests passing).

**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.5**

### Property 8: Test suite completeness

*For all* test executions after migration, the test suite should pass all 558 tests with zero failures and zero errors, maintaining 100% code coverage.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

### Example-Based Tests

The following specific examples should be verified as concrete test cases:

**Example 1: Root directory contains only init.lua**
After migration, listing source files in the root directory should return only init.lua.
**Validates: Requirement 1.1**

**Example 2: Specific import statements**
Verify these exact imports exist in the specified files:
- init.lua: `require('LuaBots.Actionable')` and `require('LuaBots.mq')`
- events.lua: `require('LuaBots.mq')` and `require('LuaBots.parser')`
- parser.lua: `require('LuaBots.mq')`
- mq.lua: `require('LuaBots.mq_stub')`

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

**Example 3: Test infrastructure preserved**
Verify that test files retain package.preload['mq.PackageMan'] setup function.
**Validates: Requirement 3.6**

**Example 4: Documentation updated**
Verify that:
- Comments in init.lua reference LuaBots/ prefix for file paths
- Documentation files reference correct file locations
- .luarc.json includes LuaBots/ in workspace paths if present

**Validates: Requirements 6.1, 6.3, 6.4**

**Example 5: Module resolution paths**
Verify these specific module loads work:
- `require('LuaBots')` returns the main module
- `require('LuaBots.Actionable')` loads from LuaBots/Actionable.lua
- `require('LuaBots.mq')` loads from LuaBots/mq.lua
- mq.lua's conditional require loads mq_stub from LuaBots/mq_stub.lua

**Validates: Requirements 7.2, 7.3, 7.4**

**Example 6: Error message clarity**
When attempting to load a non-existent module, verify the error message follows Lua's standard format indicating the search paths attempted.
**Validates: Requirement 7.5**

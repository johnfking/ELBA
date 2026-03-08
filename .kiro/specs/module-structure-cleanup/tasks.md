# Implementation Plan: Module Structure Cleanup

## Overview

This plan implements the reorganization of the LuaBots module structure by moving 5 source files from the root directory to LuaBots/, standardizing all imports to use the LuaBots. prefix, and removing package.path hacks from test files. The migration follows a strict incremental approach: move one file at a time, update all imports, run the full test suite, and validate before proceeding to the next file.

## Tasks

- [x] 1. Prepare migration infrastructure
  - Create backup of current state for rollback capability
  - Document current file locations and import patterns
  - Verify test suite baseline (558 tests passing, 100% coverage)
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 2. Migrate mq_stub.lua (no dependencies)
  - [x] 2.1 Move mq_stub.lua to LuaBots/mq_stub.lua
    - Move file from root to LuaBots/ directory
    - Verify file contents unchanged
    - Remove original file from root
    - _Requirements: 1.4, 1.7_
  
  - [x] 2.2 Run test suite after mq_stub migration
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 3. Migrate mq.lua (depends on mq_stub)
  - [x] 3.1 Move mq.lua to LuaBots/mq.lua
    - Move file from root to LuaBots/ directory
    - Verify mq.lua already uses require('LuaBots.mq_stub')
    - Remove original file from root
    - _Requirements: 1.3, 1.7, 2.6_
  
  - [x] 3.2 Update imports in dependent files
    - Update init.lua to use require('LuaBots.mq')
    - Update events.lua from require('elba.mq') to require('LuaBots.mq')
    - Update parser.lua from require('elba.mq') to require('LuaBots.mq')
    - Verify CommandExecutor.lua already uses require('LuaBots.mq')
    - _Requirements: 2.2, 2.3, 2.5, 2.7_
  
  - [x] 3.3 Run test suite after mq migration
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 4. Migrate parser.lua (depends on mq)
  - [x] 4.1 Move parser.lua to LuaBots/parser.lua
    - Move file from root to LuaBots/ directory
    - Update parser.lua import from require('elba.mq') to require('LuaBots.mq')
    - Remove original file from root
    - _Requirements: 1.6, 1.7, 2.5_
  
  - [x] 4.2 Run test suite after parser migration
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 5. Migrate events.lua (depends on mq and parser)
  - [x] 5.1 Move events.lua to LuaBots/events.lua
    - Move file from root to LuaBots/ directory
    - Update events.lua imports to use require('LuaBots.mq') and require('LuaBots.parser')
    - Remove original file from root
    - _Requirements: 1.5, 1.7, 2.3, 2.4_
  
  - [x] 5.2 Run test suite after events migration
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 6. Migrate Actionable.lua (no dependencies)
  - [x] 6.1 Move Actionable.lua to LuaBots/Actionable.lua
    - Move file from root to LuaBots/ directory
    - Verify init.lua already uses require('LuaBots.Actionable')
    - Remove original file from root
    - _Requirements: 1.2, 1.7, 2.1_
  
  - [x] 6.2 Run test suite after Actionable migration
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 7. Checkpoint - All files migrated
  - Verify only init.lua remains in root directory
  - Verify all 5 files exist in LuaBots/ directory
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 1.1_

- [x] 8. Clean up test file package.path modifications
  - [x] 8.1 Remove package.path modifications from test files
    - Search for `package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path` pattern
    - Remove all instances from spec/ directory test files
    - _Requirements: 3.1, 8.4_
  
  - [x] 8.2 Run test suite after package.path cleanup
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 9. Clean up test file package aliases
  - [x] 9.1 Remove setup_package_aliases functions from test files
    - Search for setup_package_aliases() function definitions
    - Remove function definitions and calls
    - Preserve package.preload['mq.PackageMan'] setup (test infrastructure)
    - _Requirements: 3.2, 3.6, 8.3_
  
  - [x] 9.2 Update test file imports to use standard patterns
    - Replace require('Actionable') with require('LuaBots.Actionable')
    - Replace require('CommandBuilder') with require('LuaBots.CommandBuilder')
    - Apply LuaBots. prefix to all module imports in test files
    - _Requirements: 3.3, 3.4, 3.5_
  
  - [x] 9.3 Run test suite after alias cleanup
    - Execute `busted -v spec`
    - Verify 558 tests pass with 0 failures
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 10. Checkpoint - Test files cleaned up
  - Verify no package.path modifications remain
  - Verify no package aliases remain (except mq.PackageMan)
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Update file references and documentation
  - [x] 11.1 Update comments in init.lua
    - Update file path references to use LuaBots/ prefix
    - _Requirements: 6.1_
  
  - [x] 11.2 Update .luarc.json if present
    - Add LuaBots/ to workspace library paths for LSP support
    - _Requirements: 6.4_
  
  - [x] 11.3 Update documentation files
    - Search for file location references in README, docs, comments
    - Update to reflect new structure
    - _Requirements: 6.3_

- [x] 12. Validate module resolution
  - [x] 12.1 Write property test for file relocation completeness
    - **Property 1: File relocation completeness**
    - **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6, 1.7**
    - Verify all 5 files exist in LuaBots/ and not in root
  
  - [x] 12.2 Write property test for import prefix consistency
    - **Property 2: Import prefix consistency**
    - **Validates: Requirements 2.7, 8.2**
    - Verify all require() statements use LuaBots. prefix
  
  - [x] 12.3 Write property test for test file standard imports
    - **Property 3: Test files use standard imports**
    - **Validates: Requirements 3.1, 3.2, 3.3**
    - Verify test files use standard imports without hacks
  
  - [x] 12.4 Write property test for no relative path imports
    - **Property 4: No relative path imports**
    - **Validates: Requirements 8.1**
    - Verify no ../ or ./ patterns in require() statements
  
  - [x] 12.5 Write property test for no package alias functions
    - **Property 5: No package alias functions**
    - **Validates: Requirements 8.3, 8.4**
    - Verify no setup_package_aliases() functions exist
  
  - [x] 12.6 Write property test for module resolution
    - **Property 6: Module resolution succeeds**
    - **Validates: Requirements 7.1, 7.5**
    - Verify all LuaBots modules load successfully
  
  - [x] 12.7 Write property test for backward compatibility
    - **Property 7: Backward compatibility preservation**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.5**
    - Verify public API unchanged (all tests pass)
  
  - [x] 12.8 Write property test for test suite completeness
    - **Property 8: Test suite completeness**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.4**
    - Verify 558 tests pass with 100% coverage

- [x] 13. Final validation and cleanup
  - [x] 13.1 Run full test suite with coverage
    - Execute `busted -v spec`
    - Verify 558 tests pass, 0 failures, 0 errors
    - Run `luacov` and verify 100% coverage
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  
  - [x] 13.2 Verify backward compatibility
    - Test require('LuaBots') loads successfully
    - Test LuaBots.Actionable accessible
    - Test LuaBots.Class accessible
    - Test LuaBots:stance() and LuaBots:botcreate() work
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_
  
  - [x] 13.3 Verify module resolution for all moved files
    - Test require('LuaBots.Actionable') loads from LuaBots/Actionable.lua
    - Test require('LuaBots.mq') loads from LuaBots/mq.lua
    - Test require('LuaBots.mq_stub') loads from LuaBots/mq_stub.lua
    - Test require('LuaBots.parser') loads from LuaBots/parser.lua
    - Test require('LuaBots.events') loads from LuaBots/events.lua
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 13.4 Search for obsolete patterns
    - Search codebase for require() with relative paths
    - Search codebase for require() without LuaBots. prefix
    - Search test files for setup_package_aliases()
    - Verify none found
    - _Requirements: 8.1, 8.2, 8.3_

- [x] 14. Final checkpoint - Migration complete
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional property tests and can be skipped for faster completion
- Each file migration includes immediate test validation to catch issues early
- Checkpoints ensure incremental validation at key milestones
- The migration order (mq_stub → mq → parser → events → Actionable) minimizes dependency issues
- All 558 tests must pass after each migration step before proceeding
- Rollback strategy: if any step fails, move file back and revert import changes
- Property tests validate universal correctness properties across the entire codebase
- Unit tests (existing 558 tests) validate specific functionality and edge cases

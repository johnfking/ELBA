# Implementation Plan: Functional Refactoring

## Overview

This implementation plan refactors the LuaBots library to separate pure logic from side effects. The refactoring introduces command builders (pure functions), externalizes state management, and provides dependency injection while maintaining backward compatibility. Tasks are organized to build incrementally, with early validation through property-based tests.

## Tasks

- [x] 1. Create command builder module with pure functions
  - [x] 1.1 Create CommandBuilder module structure
    - Create `LuaBots/CommandBuilder.lua` file
    - Define CommandBuilder table and module structure
    - Add LuaDoc annotations for the module
    - _Requirements: 1.1, 8.1, 8.3, 8.4_
  
  - [x] 1.2 Implement core command builders (stance, attack, guard, follow)
    - Implement `build_stance(value, act)` function
    - Implement `build_attack(value, act)` function
    - Implement `build_guard(value, act)` function
    - Implement `build_follow(value, act)` function
    - Each builder constructs command string without calling mq.cmd()
    - _Requirements: 1.1, 1.2, 8.1_
  
  - [x] 1.3 Write property tests for command builder purity
    - **Property 1: Command Builder Purity**
    - **Validates: Requirements 1.1, 8.3, 8.4**
    - Verify builders don't call mq.cmd/mq.cmdf
    - Verify builders don't modify global state
    - Verify builders don't perform I/O operations
  
  - [x] 1.4 Write property tests for command builder idempotence
    - **Property 2: Command Builder Idempotence**
    - **Validates: Requirements 8.2**
    - Verify same inputs produce identical outputs across multiple calls
  
  - [x] 1.5 Write property tests for command string format
    - **Property 3: Command String Format**
    - **Validates: Requirements 1.2**
    - Verify all command strings match `/say ^<command> [params]` format

- [x] 2. Create command executor module
  - [x] 2.1 Create CommandExecutor module
    - Create `LuaBots/CommandExecutor.lua` file
    - Implement `execute(cmd)` function that calls mq.cmd()
    - Implement `executef(fmt, ...)` function that calls mq.cmdf()
    - Add LuaDoc annotations
    - _Requirements: 1.3_
  
  - [x] 2.2 Write unit tests for command executor
    - Test that execute() calls mq.cmd() with correct command string
    - Test that executef() formats and calls mq.cmdf() correctly
    - _Requirements: 1.3_

- [x] 3. Implement HTTP client abstraction and name generator
  - [x] 3.1 Create HTTP client interface and implementations
    - Create `LuaBots/HTTPClient.lua` file
    - Implement `create_default_http_client()` using luasocket
    - Implement `create_mock_http_client(responses)` for testing
    - Add LuaDoc annotations for HTTPClient interface
    - _Requirements: 5.1, 5.3, 5.4_
  
  - [x] 3.2 Create NameGenerator module
    - Create `LuaBots/NameGenerator.lua` file
    - Implement `generate_name(race, gender, http_client)` function
    - Include race and gender mapping tables
    - Handle HTTP errors gracefully (return nil, error_message)
    - Add LuaDoc annotations
    - _Requirements: 5.2_
  
  - [x] 3.3 Write unit tests for name generator
    - Test successful name generation with mock HTTP client
    - Test HTTP failure handling
    - Test JSON parse failure handling
    - Test empty response handling
    - _Requirements: 5.2_
  
  - [x] 3.4 Write property tests for HTTP client injection
    - **Property 12: HTTP Client Injection**
    - **Validates: Requirements 5.2**
    - Verify custom HTTP client is used when provided
    - Verify returned name matches HTTP client response

- [x] 4. Refactor LuaBots module to use builders and support dependency injection
  - [x] 4.1 Update LuaBots module structure
    - Add requires for CommandBuilder, CommandExecutor, NameGenerator
    - Add requires for HTTPClient
    - Preserve existing function signatures
    - _Requirements: 7.1, 7.2_
  
  - [x] 4.2 Refactor stance, attack, guard, follow functions
    - Update each function to call CommandBuilder then CommandExecutor
    - Maintain existing function signatures
    - _Requirements: 1.2, 1.3, 7.1, 7.2_
  
  - [x] 4.3 Refactor botcreate function with HTTP injection
    - Add optional `http_client` parameter (last parameter for backward compatibility)
    - Use default HTTP client if not provided
    - Handle "AUTO" name generation using NameGenerator
    - Call CommandBuilder.build_botcreate() and CommandExecutor.execute()
    - _Requirements: 5.1, 5.2, 5.3, 7.3_
  
  - [x] 4.4 Implement remaining command builders and update LuaBots functions
    - Add builders for all remaining commands (camp, pull, etc.)
    - Update corresponding LuaBots functions to use builder + executor pattern
    - _Requirements: 1.2, 1.3, 8.1_
  
  - [x] 4.5 Write property tests for build-execute equivalence
    - **Property 4: Build-Execute Equivalence**
    - **Validates: Requirements 1.4, 7.2**
    - Verify builder + executor produces same mq.cmd call as original
    - Test across all command types
  
  - [x] 4.6 Write property tests for backward compatibility
    - **Property 13: Optional Parameter Backward Compatibility**
    - **Validates: Requirements 7.3**
    - Verify functions work identically without optional parameters
    - Test all functions with new optional parameters

- [x] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Refactor property test framework for RNG state externalization
  - [x] 6.1 Create PropertyTestState structure
    - Add `create_test_state(seed)` function
    - PropertyTestState contains rng_seed and iteration fields
    - Support PROPERTY_SEED environment variable
    - _Requirements: 2.1, 2.3_
  
  - [x] 6.2 Update property.forall() to accept and return state
    - Add optional `state` parameter to property.forall()
    - Create isolated state if not provided
    - Set math.randomseed from state.rng_seed
    - Update state.rng_seed after test execution
    - Return final state
    - _Requirements: 2.2, 2.4, 9.1_
  
  - [x] 6.3 Write property tests for RNG state determinism
    - **Property 5: RNG State Determinism**
    - **Validates: Requirements 2.2**
    - Verify same state produces same generated values across runs
  
  - [x] 6.4 Write property tests for RNG state isolation
    - **Property 6: RNG State Isolation**
    - **Validates: Requirements 2.3, 9.1, 9.2**
    - Verify tests without explicit state sharing are isolated
  
  - [x] 6.5 Write property tests for test confluence
    - **Property 15: Property Test Confluence**
    - **Validates: Requirements 9.4**
    - Verify running tests in different orders produces consistent results

- [x] 7. Refactor test capture helper
  - [x] 7.1 Create OutputSink interface and buffer implementation
    - Create `spec/output_sink.lua` file
    - Implement `create_buffer_sink()` function
    - OutputSink has write() and get_output() methods
    - _Requirements: 3.1, 3.4_
  
  - [x] 7.2 Update capture() function to use OutputSink
    - Add optional `sink` parameter to capture()
    - Create buffer sink if not provided
    - Temporarily replace io.write with sink.write
    - Use pcall to ensure io.write restoration on error
    - Return sink.get_output()
    - _Requirements: 3.2, 3.3_
  
  - [x] 7.3 Write property tests for output capture isolation
    - **Property 7: Output Capture Isolation**
    - **Validates: Requirements 3.2**
    - Verify output goes to sink, not stdout
  
  - [x] 7.4 Write property tests for output capture restoration
    - **Property 8: Output Capture Restoration**
    - **Validates: Requirements 3.3**
    - Verify io.write is restored after capture
  
  - [x] 7.5 Write property tests for concurrent capture independence
    - **Property 9: Concurrent Capture Independence**
    - **Validates: Requirements 3.4**
    - Verify concurrent captures maintain separate buffers

- [x] 8. Refactor package setup functions
  - [x] 8.1 Create package configuration structure
    - Create `spec/package_config.lua` file
    - Implement `create_package_config()` function
    - PackageConfig contains aliases, preload, loaded tables
    - _Requirements: 4.1_
  
  - [x] 8.2 Implement apply and restore functions
    - Implement `apply_package_config(config)` function
    - Implement `restore_package_config(backup)` function
    - apply_package_config returns backup of original state
    - _Requirements: 4.2, 4.3_
  
  - [x] 8.3 Write property tests for package setup purity
    - **Property 11: Package Setup Purity**
    - **Validates: Requirements 4.4**
    - Verify create_package_config doesn't modify globals
  
  - [x] 8.4 Write property tests for package configuration round-trip
    - **Property 10: Package Configuration Round-Trip**
    - **Validates: Requirements 4.3**
    - Verify apply + restore returns to original state

- [x] 9. Add command capture mode to mq_stub
  - [x] 9.1 Implement command capture in mq_stub
    - Add capture_mode flag and command_buffer table
    - Implement `enable_capture()` function
    - Implement `disable_capture()` function
    - Implement `get_captured_commands()` function
    - Implement `clear_captured_commands()` function
    - Update cmd() and cmdf() to append to buffer in capture mode
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  
  - [x] 9.2 Write property tests for command capture accumulation
    - **Property 14: Command Capture Accumulation**
    - **Validates: Requirements 10.2**
    - Verify all commands are captured in order
  
  - [x] 9.3 Write unit tests for mq_stub capture mode
    - Test enable/disable capture
    - Test get and clear captured commands
    - Test capture mode doesn't write to stdout
    - _Requirements: 10.1, 10.3, 10.4_

- [x] 10. Add documentation for side effects
  - [x] 10.1 Annotate all functions with side effect documentation
    - Add LuaDoc comments to all LuaBots functions
    - Document specific side effects (I/O, state mutation, network)
    - Mark pure functions explicitly
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 10.2 Create side effects documentation guide
    - Create `docs/side-effects.md` file
    - List all pure functions
    - List all functions with side effects and their types
    - Document recommended patterns for handling side effects
    - _Requirements: 6.3, 6.4_

- [x] 11. Final checkpoint - Run all existing tests for backward compatibility
  - Run complete existing test suite
  - Verify all tests pass without modification
  - Ensure backward compatibility is maintained
  - _Requirements: 7.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- All existing tests must pass to ensure backward compatibility (Requirement 7.4)
- The refactoring maintains existing function signatures while adding optional parameters

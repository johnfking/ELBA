# Requirements Document

## Introduction

This document specifies requirements for refactoring the LuaBots library to reduce side effects and adopt a more functional programming approach. The current implementation has several functions that directly modify global state, perform I/O operations, or mutate shared resources, making the code harder to test, reason about, and maintain. This refactoring will separate pure logic from side effects, making the codebase more modular and testable.

## Glossary

- **LuaBots**: The main library module that provides bot command functionality for EverQuest Emulator
- **Command_Function**: A function in the LuaBots module that sends bot commands (e.g., stance, attack, botcreate)
- **Property_Test_Framework**: The property-based testing framework in spec/property.lua
- **Test_Helper**: Functions in test files that assist with testing (e.g., capture, setup_package_aliases)
- **Side_Effect**: An operation that modifies state outside its local scope or performs I/O
- **Pure_Function**: A function that always returns the same output for the same input and has no side effects
- **Command_Builder**: A function that constructs command strings without executing them
- **RNG_State**: The random number generator state used by the property testing framework

## Requirements

### Requirement 1: Separate Command Construction from Execution

**User Story:** As a developer, I want command construction separated from command execution, so that I can test command logic without triggering actual side effects.

#### Acceptance Criteria

1. THE Command_Builder SHALL construct command strings without calling mq.cmd() or mq.cmdf()
2. WHEN a Command_Function is called, THE Command_Builder SHALL return a command string representation
3. THE LuaBots SHALL provide an execute function that takes a command string and performs the side effect
4. FOR ALL Command_Functions, constructing a command then executing it SHALL produce the same result as the current implementation (round-trip property)

### Requirement 2: Externalize RNG State Management

**User Story:** As a test developer, I want RNG state management externalized from the property test framework, so that I can control randomness and reproduce test failures.

#### Acceptance Criteria

1. THE Property_Test_Framework SHALL accept an RNG state parameter instead of modifying global math.randomseed
2. WHEN property.forall() is called with an RNG state, THE Property_Test_Framework SHALL use that state for generation
3. WHEN property.forall() is called without an RNG state, THE Property_Test_Framework SHALL create a new isolated state
4. THE Property_Test_Framework SHALL return the final RNG state after test execution

### Requirement 3: Refactor Test Capture Helper

**User Story:** As a test developer, I want the capture helper to avoid modifying global io.write, so that tests are isolated and don't affect each other.

#### Acceptance Criteria

1. THE Test_Helper SHALL accept an output sink parameter instead of modifying global io.write
2. WHEN capture() is called, THE Test_Helper SHALL redirect output to the provided sink
3. WHEN capture() completes, THE Test_Helper SHALL restore the original io.write without side effects
4. THE Test_Helper SHALL use a local output buffer that doesn't modify global state

### Requirement 4: Refactor Package Setup Functions

**User Story:** As a test developer, I want package setup functions to return configuration data instead of modifying global package tables, so that test setup is explicit and reversible.

#### Acceptance Criteria

1. THE Test_Helper SHALL return package alias configuration as a data structure
2. THE Test_Helper SHALL provide a function to apply package configuration
3. THE Test_Helper SHALL provide a function to restore original package state
4. WHEN setup functions are called, THE Test_Helper SHALL not modify package.preload or package.loaded directly

### Requirement 5: Make HTTP Requests Configurable

**User Story:** As a developer, I want HTTP requests in botcreate to be configurable, so that I can test the function without making actual network calls.

#### Acceptance Criteria

1. THE LuaBots:botcreate SHALL accept an optional HTTP client parameter
2. WHEN botcreate is called with a custom HTTP client, THE LuaBots SHALL use that client for name generation
3. WHEN botcreate is called without a custom HTTP client, THE LuaBots SHALL use the default HTTP implementation
4. THE LuaBots SHALL provide a mock HTTP client for testing purposes

### Requirement 6: Document Side Effect Boundaries

**User Story:** As a developer, I want clear documentation of which functions have side effects, so that I can understand the impact of calling each function.

#### Acceptance Criteria

1. THE LuaBots SHALL annotate all functions with side effects using LuaDoc comments
2. THE LuaBots SHALL document the specific side effects for each function (I/O, state mutation, network)
3. THE LuaBots SHALL provide a list of pure functions that have no side effects
4. THE LuaBots SHALL document the recommended patterns for handling side effects

### Requirement 7: Maintain Backward Compatibility

**User Story:** As a library user, I want the refactored API to maintain backward compatibility, so that my existing code continues to work without changes.

#### Acceptance Criteria

1. THE LuaBots SHALL preserve all existing function signatures
2. WHEN existing code calls LuaBots functions with current parameters, THE LuaBots SHALL behave identically to the pre-refactor version
3. THE LuaBots SHALL provide new optional parameters for side effect control without breaking existing usage
4. FOR ALL existing test cases, the refactored implementation SHALL pass without modification

### Requirement 8: Provide Pure Command Builders

**User Story:** As a developer, I want pure functions that build commands, so that I can compose and test command logic without side effects.

#### Acceptance Criteria

1. THE LuaBots SHALL provide a pure function for each command that returns a command string
2. WHEN a pure command builder is called multiple times with the same inputs, THE LuaBots SHALL return identical command strings (idempotence)
3. THE LuaBots SHALL not perform any I/O operations in pure command builders
4. THE LuaBots SHALL not modify any global state in pure command builders

### Requirement 9: Isolate Test Framework State

**User Story:** As a test developer, I want each property test to have isolated state, so that tests don't interfere with each other.

#### Acceptance Criteria

1. WHEN property.forall() is called, THE Property_Test_Framework SHALL create isolated generator state
2. WHEN multiple property tests run sequentially, THE Property_Test_Framework SHALL not share state between tests
3. THE Property_Test_Framework SHALL provide a way to explicitly share state when needed
4. FOR ALL property tests, running them in different orders SHALL produce consistent results (confluence)

### Requirement 10: Refactor mq_stub Side Effects

**User Story:** As a test developer, I want the mq_stub to capture commands instead of writing to stdout, so that I can verify command execution in tests.

#### Acceptance Criteria

1. THE mq_stub SHALL provide a command capture mode that stores commands in a buffer
2. WHEN mq.cmd() is called in capture mode, THE mq_stub SHALL append the command to the buffer
3. THE mq_stub SHALL provide a function to retrieve captured commands
4. THE mq_stub SHALL provide a function to clear the command buffer

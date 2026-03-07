# Requirements Document

## Introduction

This feature enhances the LuaBots testing suite by implementing comprehensive property-based testing. The current test suite validates basic functionality through example-based tests but lacks systematic verification of invariants, edge cases, and error conditions. Property-based testing will generate random inputs to verify that system properties hold across a wide range of scenarios, improving confidence in the correctness of the bot command system.

## Glossary

- **Property_Based_Test**: A test that verifies a property holds for many randomly generated inputs
- **Test_Generator**: A component that produces random valid test data
- **Actionable_System**: The bot selector system that determines which bots receive commands
- **Command_Formatter**: The system that converts bot commands into MacroQuest command strings
- **Enum_System**: The collection of enumeration types (Class, Race, Gender, etc.)
- **MQ_Stub**: The test double for the MacroQuest library
- **Invariant**: A property that must always be true regardless of inputs
- **Round_Trip_Property**: A property where applying an operation and its inverse returns to the original value

## Requirements

### Requirement 1: Property-Based Testing Framework

**User Story:** As a developer, I want a property-based testing framework integrated with busted, so that I can verify system properties across many random inputs.

#### Acceptance Criteria

1. THE Test_Generator SHALL generate random integers within specified ranges
2. THE Test_Generator SHALL generate random strings with configurable length and character sets
3. THE Test_Generator SHALL generate random selections from provided lists
4. THE Test_Generator SHALL generate random boolean values
5. THE Test_Generator SHALL support configurable test iteration counts
6. WHEN a property test fails, THE Test_Generator SHALL report the failing input that violated the property
7. THE Test_Generator SHALL integrate with busted's assertion framework

### Requirement 2: Actionable Selector Validation

**User Story:** As a developer, I want comprehensive tests for the Actionable selector system, so that I can ensure selectors are validated correctly.

#### Acceptance Criteria

1. FOR ALL actionable types that require selectors, WHEN created without a selector, THE Actionable_System SHALL raise an error
2. FOR ALL actionable types that do not require selectors, WHEN created with a selector, THE Actionable_System SHALL raise an error
3. FOR ALL valid actionable type and selector combinations, THE Actionable_System SHALL create a valid Actionable instance
4. FOR ALL Actionable instances, THE tostring method SHALL produce a string containing the actionable type
5. FOR ALL Actionable instances with selectors, THE tostring method SHALL produce a string containing both type and selector
6. FOR ALL Actionable instances without selectors, THE tostring method SHALL produce a string containing only the type

### Requirement 3: Command Format Invariant Testing

**User Story:** As a developer, I want to verify command formatting invariants, so that I can ensure all bot commands follow the correct format.

#### Acceptance Criteria

1. FOR ALL bot commands, THE Command_Formatter SHALL produce output starting with "/say ^"
2. FOR ALL bot commands with parameters, THE Command_Formatter SHALL separate parameters with single spaces
3. FOR ALL bot commands with Actionable selectors, THE Command_Formatter SHALL append the Actionable string at the end
4. FOR ALL bot commands, THE Command_Formatter SHALL produce deterministic output for identical inputs
5. FOR ALL bot commands with nil parameters, THE Command_Formatter SHALL omit those parameters from the output
6. FOR ALL bot commands, THE Command_Formatter SHALL convert all parameters to strings using tostring

### Requirement 4: Enum Value Testing

**User Story:** As a developer, I want to verify that all enum values produce valid command strings, so that I can ensure enums integrate correctly with the command system.

#### Acceptance Criteria

1. FOR ALL Class enum values, WHEN used in a byclass command, THE Command_Formatter SHALL produce a valid command string
2. FOR ALL Race enum values, WHEN used in a byrace command, THE Command_Formatter SHALL produce a valid command string
3. FOR ALL Gender enum values, WHEN used in botcreate, THE Command_Formatter SHALL produce a valid command string
4. FOR ALL SpellType enum values, WHEN used in cast or spell threshold commands, THE Command_Formatter SHALL produce a valid command string
5. FOR ALL Stance enum values, WHEN used in stance command, THE Command_Formatter SHALL produce a valid command string
6. FOR ALL MaterialSlot enum values, WHEN used in botdyearmor command, THE Command_Formatter SHALL produce a valid command string
7. FOR ALL PetType enum values, WHEN used in petsettype command, THE Command_Formatter SHALL produce a valid command string
8. FOR ALL Slot enum values, WHEN used in clickitem command, THE Command_Formatter SHALL produce a valid command string

### Requirement 5: Edge Case and Error Condition Testing

**User Story:** As a developer, I want systematic testing of edge cases and error conditions, so that I can ensure the system handles invalid inputs gracefully.

#### Acceptance Criteria

1. WHEN an invalid actionable type is provided, THE Actionable_System SHALL raise an error with a descriptive message
2. WHEN nil is provided as an actionable type, THE Actionable_System SHALL raise an error
3. WHEN empty strings are provided as selectors for actionable types requiring selectors, THE Actionable_System SHALL create a valid Actionable instance
4. WHEN very long strings are provided as selectors, THE Actionable_System SHALL create a valid Actionable instance
5. WHEN special characters are provided in selectors, THE Actionable_System SHALL create a valid Actionable instance
6. WHEN numeric values are provided where strings are expected, THE Command_Formatter SHALL convert them to strings
7. WHEN boolean values are provided as parameters, THE Command_Formatter SHALL convert them to strings

### Requirement 6: MQ Stub Consistency Testing

**User Story:** As a developer, I want to verify the MQ stub behaves consistently, so that I can trust test results using the stub.

#### Acceptance Criteria

1. FOR ALL command strings, WHEN passed to mq.cmd, THE MQ_Stub SHALL output the command followed by a newline
2. FOR ALL format strings and arguments, WHEN passed to mq.cmdf, THE MQ_Stub SHALL produce output equivalent to string.format followed by mq.cmd
3. FOR ALL delay values, WHEN passed to mq.delay, THE MQ_Stub SHALL complete without error
4. FOR ALL event registrations, THE MQ_Stub SHALL store the callback function
5. FOR ALL event triggers, THE MQ_Stub SHALL invoke the registered callback with provided arguments
6. WHEN an event is unregistered, THE MQ_Stub SHALL not invoke the callback on subsequent triggers

### Requirement 7: Command Parameter Combination Testing

**User Story:** As a developer, I want to test various combinations of command parameters, so that I can ensure commands handle optional parameters correctly.

#### Acceptance Criteria

1. FOR ALL commands with optional value parameters, WHEN called without the value parameter, THE Command_Formatter SHALL produce a valid command string
2. FOR ALL commands with optional Actionable parameters, WHEN called without the Actionable parameter, THE Command_Formatter SHALL produce a valid command string
3. FOR ALL commands with multiple parameters, WHEN called with all parameters, THE Command_Formatter SHALL include all parameters in the correct order
4. FOR ALL commands accepting two value parameters, WHEN called with both values, THE Command_Formatter SHALL include both values in the correct order
5. FOR ALL commands, WHEN called with maximum valid parameter values, THE Command_Formatter SHALL produce a valid command string

### Requirement 8: Actionable Type Coverage Testing

**User Story:** As a developer, I want to verify all Actionable types are tested, so that I can ensure complete coverage of the selector system.

#### Acceptance Criteria

1. THE Property_Based_Test SHALL verify all actionable types in ActionableType enum
2. THE Property_Based_Test SHALL verify all static constructor methods on Actionable module
3. FOR ALL actionable types requiring selectors, THE Property_Based_Test SHALL verify behavior with various selector values
4. FOR ALL actionable types not requiring selectors, THE Property_Based_Test SHALL verify they reject selector arguments
5. THE Property_Based_Test SHALL verify the RequiresSelector table matches the actual behavior of constructor methods

### Requirement 9: Bot Creation Testing

**User Story:** As a developer, I want comprehensive testing of bot creation, so that I can ensure bots are created with valid parameters.

#### Acceptance Criteria

1. FOR ALL valid combinations of name, class, race, and gender, THE botcreate command SHALL produce a valid command string
2. WHEN botcreate is called, THE Command_Formatter SHALL return a table containing Name, Class, Race, and Gender fields
3. FOR ALL botcreate calls, THE returned table SHALL match the input parameters
4. WHEN botcreate is called with name "AUTO", THE system SHALL attempt to generate a name from the API
5. WHEN the name generation API fails, THE botcreate command SHALL not execute and SHALL print an error message

### Requirement 10: Metamorphic Property Testing

**User Story:** As a developer, I want to verify metamorphic properties of the command system, so that I can ensure related operations maintain expected relationships.

#### Acceptance Criteria

1. FOR ALL commands with Actionable parameters, THE length of the command string with Actionable SHALL be greater than the length without Actionable
2. FOR ALL commands with value parameters, THE length of the command string with parameters SHALL be greater than or equal to the base command length
3. FOR ALL Actionable instances, THE length of tostring output SHALL be greater than zero
4. FOR ALL commands, WHEN called twice with identical parameters, THE output SHALL be identical
5. FOR ALL enum values, THE tostring conversion SHALL produce a non-empty string

# Implementation Plan: Comprehensive Property-Based Testing

## Overview

This plan implements a property-based testing framework for the LuaBots library, integrated with the busted test framework. The implementation consists of three phases: building the core framework, creating test data generators, and implementing 26 correctness properties across four test suite files. Each property test will run 100 iterations with randomly generated inputs to verify system invariants.

## Tasks

- [x] 1. Set up property-based testing framework core
  - [x] 1.1 Create spec/property.lua with module structure
    - Implement module table and return statement
    - Add internal RNG state management
    - _Requirements: 1.1, 1.5_

  - [x] 1.2 Implement primitive generators (integer, boolean)
    - Implement property.integer(min, max) generator
    - Implement property.boolean() generator
    - Add validation for min <= max constraint
    - _Requirements: 1.1, 1.4_

  - [x] 1.3 Implement string and list generators
    - Implement property.string(len_min, len_max, charset) generator
    - Implement property.oneof(list) generator with empty list validation
    - Add default alphanumeric charset
    - _Requirements: 1.2, 1.3_

  - [x] 1.4 Implement property.forall test runner
    - Accept generators table, test function, and options
    - Execute test function for configurable iterations (default 100)
    - Capture and report failing inputs with property name
    - Integrate with busted assertions
    - _Requirements: 1.5, 1.6, 1.7_

  - [x]* 1.5 Add property.sample utility function
    - Generate sample values from a generator for debugging
    - Accept generator and count parameters
    - _Requirements: 1.6_

- [x] 2. Checkpoint - Verify framework basics
  - Ensure property.lua loads without errors
  - Manually test that generators produce expected value types
  - Verify forall executes multiple iterations

- [x] 3. Implement domain-specific test generators
  - [x] 3.1 Create spec/generators.lua with module structure
    - Set up module table and require property.lua
    - Import primitive generators
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.2 Implement Actionable type generators
    - Implement actionable_type_requiring_selector() using RequiresSelector table
    - Implement actionable_type_not_requiring_selector() 
    - Implement selector_string() with various lengths and characters
    - _Requirements: 2.1, 2.2, 5.3, 5.4, 5.5_

  - [x] 3.3 Implement Actionable instance generators
    - Implement actionable_with_selector() combining type and selector
    - Implement actionable_without_selector() for types not requiring selectors
    - Implement any_actionable() that generates any valid Actionable
    - _Requirements: 2.3, 2.4, 2.5, 2.6_

  - [x] 3.4 Implement enum value generators
    - Implement class_value(), race_value(), gender_value() generators
    - Implement spell_type_value(), stance_value() generators
    - Implement material_slot_value(), pet_type_value(), slot_value() generators
    - Implement any_enum_value() that selects from all enum types
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

  - [x] 3.5 Implement command and parameter generators
    - Implement bot_name() generator for valid bot names
    - Implement numeric_parameter() for command values
    - Implement string_parameter() for text parameters
    - Implement command_name() generator
    - _Requirements: 3.6, 5.6, 5.7, 7.5_

- [x] 4. Checkpoint - Verify generators work correctly
  - Test that generators produce valid domain values
  - Verify enum generators cover all enum values
  - Check that Actionable generators respect selector requirements

- [x] 5. Implement Actionable property tests
  - [x] 5.1 Create spec/property_actionable_spec.lua with busted structure
    - Set up describe block for "Actionable properties"
    - Require property, generators, and Actionable modules
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 5.2 Implement Property 1: Types requiring selectors error without them
    - Use actionable_type_requiring_selector() generator
    - Assert error raised when creating Actionable without selector
    - Tag with comment: Feature comprehensive-property-based-testing, Property 1
    - _Requirements: 2.1_

  - [x] 5.3 Implement Property 2: Types not requiring selectors error with them
    - Use actionable_type_not_requiring_selector() and selector_string() generators
    - Assert error raised when creating Actionable with selector
    - Tag with comment: Feature comprehensive-property-based-testing, Property 2
    - _Requirements: 2.2_

  - [x] 5.4 Implement Property 3: Valid combinations create instances
    - Use any_actionable() generator
    - Assert Actionable instance created successfully
    - Verify instance is not nil and has expected type
    - Tag with comment: Feature comprehensive-property-based-testing, Property 3
    - _Requirements: 2.3_

  - [x] 5.5 Implement Property 4: Actionable tostring format correctness
    - Use any_actionable() generator
    - Assert tostring output contains actionable type
    - Assert tostring output contains selector when present
    - Tag with comment: Feature comprehensive-property-based-testing, Property 4
    - _Requirements: 2.4, 2.5, 2.6, 10.3_

  - [x] 5.6 Implement Property 12: Invalid actionable types raise errors
    - Generate random invalid type strings
    - Assert error raised with descriptive message
    - Tag with comment: Feature comprehensive-property-based-testing, Property 12
    - _Requirements: 5.1, 5.2_

  - [x] 5.7 Implement Property 13: Long selectors are accepted
    - Generate selectors up to 1000 characters
    - Assert Actionable created successfully
    - Tag with comment: Feature comprehensive-property-based-testing, Property 13
    - _Requirements: 5.4_

  - [x] 5.8 Implement Property 14: Special characters in selectors are accepted
    - Generate selectors with spaces, punctuation, unicode
    - Assert Actionable created successfully
    - Tag with comment: Feature comprehensive-property-based-testing, Property 14
    - _Requirements: 5.5_

  - [x] 5.9 Implement Property 23: RequiresSelector table matches behavior
    - Verify RequiresSelector table entries match actual constructor behavior
    - Test both positive and negative cases
    - Tag with comment: Feature comprehensive-property-based-testing, Property 23
    - _Requirements: 8.5_

- [x] 6. Implement command formatting property tests
  - [x] 6.1 Create spec/property_commands_spec.lua with busted structure
    - Set up describe block for "Command formatting properties"
    - Require property, generators, LuaBots, and mq modules
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 6.2 Implement Property 5: All commands start with "/say ^"
    - Generate various bot commands with random parameters
    - Assert all outputs start with "/say ^" prefix
    - Tag with comment: Feature comprehensive-property-based-testing, Property 5
    - _Requirements: 3.1_

  - [x] 6.3 Implement Property 6: Command parameters are space-separated
    - Generate commands with multiple non-nil parameters
    - Assert parameters separated by single spaces
    - Tag with comment: Feature comprehensive-property-based-testing, Property 6
    - _Requirements: 3.2_

  - [x] 6.4 Implement Property 7: Actionables appear at command end
    - Generate commands with Actionable parameters
    - Assert Actionable string representation at end of output
    - Tag with comment: Feature comprehensive-property-based-testing, Property 7
    - _Requirements: 3.3_

  - [x] 6.5 Implement Property 8: Command output is deterministic
    - Generate commands and call twice with identical parameters
    - Assert outputs are identical
    - Tag with comment: Feature comprehensive-property-based-testing, Property 8
    - _Requirements: 3.4, 10.4_

  - [x] 6.6 Implement Property 9: Nil parameters are omitted
    - Generate commands with some nil parameters
    - Assert nil parameters not in output string
    - Tag with comment: Feature comprehensive-property-based-testing, Property 9
    - _Requirements: 3.5_

  - [x] 6.7 Implement Property 10: Parameters are converted to strings
    - Generate commands with numbers, booleans, enums
    - Assert all parameters converted using tostring
    - Tag with comment: Feature comprehensive-property-based-testing, Property 10
    - _Requirements: 3.6, 5.6, 5.7_

  - [x] 6.8 Implement Property 20: Optional parameters can be omitted
    - Generate commands with optional value and Actionable parameters
    - Call without optional parameters and assert valid output
    - Tag with comment: Feature comprehensive-property-based-testing, Property 20
    - _Requirements: 7.1, 7.2_

  - [x] 6.9 Implement Property 21: Multi-parameter commands preserve order
    - Generate commands with all parameters provided
    - Assert parameters appear in correct order per function signature
    - Tag with comment: Feature comprehensive-property-based-testing, Property 21
    - _Requirements: 7.3, 7.4_

  - [x] 6.10 Implement Property 22: Maximum parameter values are handled
    - Generate commands with maximum valid values (255 for colors, 100 for percentages)
    - Assert valid command output produced
    - Tag with comment: Feature comprehensive-property-based-testing, Property 22
    - _Requirements: 7.5_

  - [x] 6.11 Implement Property 25: Commands with Actionables are longer
    - Generate same command with and without Actionable
    - Assert length with Actionable > length without
    - Tag with comment: Feature comprehensive-property-based-testing, Property 25
    - _Requirements: 10.1_

  - [x] 6.12 Implement Property 26: Commands with parameters are longer or equal
    - Generate command with and without value parameters
    - Assert length with parameters >= base command length
    - Tag with comment: Feature comprehensive-property-based-testing, Property 26
    - _Requirements: 10.2_

- [x] 7. Checkpoint - Verify command tests pass
  - Run busted on property_commands_spec.lua
  - Verify all command formatting properties pass
  - Check that failures report useful input values

- [x] 8. Implement enum integration property tests
  - [x] 8.1 Create spec/property_enums_spec.lua with busted structure
    - Set up describe block for "Enum integration properties"
    - Require property, generators, LuaBots, and all enum modules
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

  - [x] 8.2 Implement Property 11: All enum values produce valid commands
    - Test Class enum values with byclass command
    - Test Race enum values with byrace command
    - Test Gender enum values with botcreate command
    - Test SpellType enum values with cast and spell threshold commands
    - Test Stance enum values with stance command
    - Test MaterialSlot enum values with botdyearmor command
    - Test PetType enum values with petsettype command
    - Test Slot enum values with clickitem command
    - Assert all produce valid command strings starting with "/say ^"
    - Tag with comment: Feature comprehensive-property-based-testing, Property 11
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 10.5_

- [x] 9. Implement MQ stub property tests
  - [x] 9.1 Create spec/property_mq_stub_spec.lua with busted structure
    - Set up describe block for "MQ stub properties"
    - Require property, generators, and mq modules
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [x] 9.2 Implement Property 15: MQ stub outputs commands with newlines
    - Generate random command strings
    - Pass to mq.cmd and assert output ends with newline
    - Tag with comment: Feature comprehensive-property-based-testing, Property 15
    - _Requirements: 6.1_

  - [x] 9.3 Implement Property 16: MQ cmdf is equivalent to format then cmd
    - Generate format strings and arguments
    - Assert mq.cmdf output equals string.format + mq.cmd
    - Tag with comment: Feature comprehensive-property-based-testing, Property 16
    - _Requirements: 6.2_

  - [x] 9.4 Implement Property 17: MQ delay completes without error
    - Generate delay values between 0 and 10000
    - Assert mq.delay completes without raising error
    - Tag with comment: Feature comprehensive-property-based-testing, Property 17
    - _Requirements: 6.3_

  - [x] 9.5 Implement Property 18: MQ event registration stores callbacks
    - Generate event names and callback functions
    - Register events and verify callbacks stored and retrievable
    - Tag with comment: Feature comprehensive-property-based-testing, Property 18
    - _Requirements: 6.4_

  - [x] 9.6 Implement Property 19: MQ event triggers invoke callbacks
    - Register events with callbacks
    - Trigger events with arguments
    - Assert callbacks invoked with exact arguments
    - Tag with comment: Feature comprehensive-property-based-testing, Property 19
    - _Requirements: 6.5_

- [x] 10. Implement bot creation property tests
  - [x] 10.1 Add botcreate property tests to property_commands_spec.lua
    - Implement Property 24: Botcreate produces valid commands for all combinations
    - Generate valid combinations of name, class, race, gender
    - Assert command starts with "/say ^botcreate"
    - Assert return table has Name, Class, Race, Gender fields matching inputs
    - Tag with comment: Feature comprehensive-property-based-testing, Property 24
    - _Requirements: 9.1, 9.2, 9.3_

- [x] 11. Final integration and verification
  - [x] 11.1 Add test execution documentation
    - Document how to run all tests with busted -v spec
    - Document how to run only property tests with busted -v spec/property_*.lua
    - Document seed configuration for reproducibility
    - _Requirements: 1.5_

  - [x] 11.2 Verify all 26 properties are implemented
    - Cross-reference each property from design document
    - Ensure each has corresponding test with proper tagging
    - Verify requirement coverage is complete
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x]* 11.3 Run full test suite and verify execution time
    - Run busted -v spec and measure execution time
    - Verify property tests complete in 5-10 seconds
    - Verify total suite completes in 10-15 seconds
    - _Requirements: 1.5_

- [x] 12. Final checkpoint - Complete test suite verification
  - Ensure all tests pass with busted -v spec
  - Verify existing example-based tests still pass
  - Confirm property-based tests provide comprehensive coverage

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each property test runs 100 iterations by default for comprehensive coverage
- The framework integrates seamlessly with existing busted tests in init_spec.lua
- Property tests complement rather than replace example-based tests
- All 26 correctness properties from the design document are covered
- Test execution time is acceptable at 10-15 seconds for the full suite

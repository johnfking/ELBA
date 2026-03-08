# Requirements Document

## Introduction

This document specifies requirements for reorganizing the LuaBots module structure to follow Lua best practices. Currently, the repository has a hybrid structure with some source files in the root directory and others in the LuaBots/ subdirectory, creating confusion and requiring package.path hacks in test files. The goal is to establish a clean, standard module structure where only init.lua remains in the root, with all other source files properly organized in subdirectories.

## Glossary

- **Root_Directory**: The top-level directory of the LuaBots repository
- **LuaBots_Module**: The main module directory at LuaBots/ containing library implementation files
- **Source_File**: A Lua implementation file containing module code (excluding test files)
- **Test_File**: A Lua file in the spec/ directory containing test specifications
- **Module_Import**: A require() statement that loads a Lua module
- **Package_Path**: The Lua package.path variable that controls module search paths
- **Package_Alias**: An entry in package.preload that redirects one module name to another
- **Test_Suite**: The complete set of 558 tests verified by busted
- **External_User**: A developer using LuaBots as a library in their own code
- **Backward_Compatibility**: The property that existing external code continues to work without modification

## Requirements

### Requirement 1: Relocate Root Source Files

**User Story:** As a repository maintainer, I want all source files except init.lua moved to the LuaBots/ directory, so that the module structure follows Lua conventions.

#### Acceptance Criteria

1. THE File_System SHALL contain exactly one source file (init.lua) in Root_Directory after reorganization
2. THE LuaBots_Module SHALL contain Actionable.lua after reorganization
3. THE LuaBots_Module SHALL contain mq.lua after reorganization
4. THE LuaBots_Module SHALL contain mq_stub.lua after reorganization
5. THE LuaBots_Module SHALL contain events.lua after reorganization
6. THE LuaBots_Module SHALL contain parser.lua after reorganization
7. WHEN a Source_File is moved to LuaBots_Module, THE File_System SHALL remove the original file from Root_Directory

### Requirement 2: Update Module Imports

**User Story:** As a developer, I want all module imports to use the LuaBots. prefix consistently, so that the codebase has a uniform import style.

#### Acceptance Criteria

1. THE init.lua SHALL use require('LuaBots.Actionable') for importing Actionable
2. THE init.lua SHALL use require('LuaBots.mq') for importing mq
3. THE events.lua SHALL use require('LuaBots.mq') for importing mq
4. THE events.lua SHALL use require('LuaBots.parser') for importing parser
5. THE parser.lua SHALL use require('LuaBots.mq') for importing mq
6. THE mq.lua SHALL use require('LuaBots.mq_stub') for importing mq_stub
7. WHEN a Module_Import references a file in LuaBots_Module, THE Module_Import SHALL use the LuaBots. prefix

### Requirement 3: Remove Test File Package Hacks

**User Story:** As a test maintainer, I want test files to use standard module imports without package.path modifications, so that tests are simpler and more maintainable.

#### Acceptance Criteria

1. THE Test_File SHALL NOT modify Package_Path with custom search patterns
2. THE Test_File SHALL NOT create Package_Alias entries for source modules
3. THE Test_File SHALL use require('LuaBots.ModuleName') for all LuaBots module imports
4. WHEN a Test_File imports Actionable, THE Test_File SHALL use require('LuaBots.Actionable')
5. WHEN a Test_File imports CommandBuilder, THE Test_File SHALL use require('LuaBots.CommandBuilder')
6. THE Test_File SHALL retain package.preload entries for mq.PackageMan (test infrastructure)

### Requirement 4: Maintain Backward Compatibility

**User Story:** As an external user, I want my existing code to continue working without changes, so that I can upgrade LuaBots without breaking my application.

#### Acceptance Criteria

1. WHEN External_User code uses require('LuaBots'), THE Module_System SHALL return the LuaBots module
2. WHEN External_User code accesses LuaBots.Actionable, THE Module_System SHALL provide the Actionable module
3. WHEN External_User code accesses LuaBots.Class, THE Module_System SHALL provide the Class enum
4. WHEN External_User code calls LuaBots:stance(), THE Module_System SHALL execute the stance command
5. WHEN External_User code calls LuaBots:botcreate(), THE Module_System SHALL execute the botcreate command
6. FOR ALL public API functions in LuaBots, THE Module_System SHALL maintain identical behavior after reorganization

### Requirement 5: Preserve Test Coverage

**User Story:** As a quality assurance engineer, I want all 558 tests to pass after reorganization, so that I know no functionality was broken.

#### Acceptance Criteria

1. WHEN Test_Suite is executed with busted, THE Test_Suite SHALL pass all 558 tests
2. WHEN Test_Suite is executed with busted, THE Test_Suite SHALL report zero failures
3. WHEN Test_Suite is executed with busted, THE Test_Suite SHALL report zero errors
4. THE Test_Suite SHALL maintain 100% code coverage after reorganization
5. WHEN a test imports a moved module, THE test SHALL successfully load the module from its new location

### Requirement 6: Update File References

**User Story:** As a developer, I want all file references updated to reflect new locations, so that documentation and tooling remain accurate.

#### Acceptance Criteria

1. WHEN init.lua contains a comment referencing a source file, THE comment SHALL use the LuaBots/ prefix for the file path
2. WHEN a test file contains a require() statement for a moved file, THE require() statement SHALL use the new module path
3. WHEN documentation references a source file location, THE documentation SHALL reflect the new file structure
4. THE .luarc.json SHALL include LuaBots/ in workspace library paths if needed for LSP support

### Requirement 7: Validate Module Resolution

**User Story:** As a developer, I want to verify that all modules resolve correctly, so that I can be confident the reorganization is complete.

#### Acceptance Criteria

1. WHEN init.lua is loaded with require('LuaBots'), THE Module_System SHALL successfully load all dependencies
2. WHEN a test file requires LuaBots.Actionable, THE Module_System SHALL load Actionable from LuaBots/Actionable.lua
3. WHEN a test file requires LuaBots.mq, THE Module_System SHALL load mq from LuaBots/mq.lua
4. WHEN mq.lua loads mq_stub, THE Module_System SHALL load mq_stub from LuaBots/mq_stub.lua
5. IF a Module_Import fails to resolve, THEN THE Module_System SHALL report a clear error message indicating the missing module

### Requirement 8: Clean Up Obsolete Patterns

**User Story:** As a code reviewer, I want obsolete import patterns removed, so that the codebase doesn't contain confusing legacy code.

#### Acceptance Criteria

1. THE codebase SHALL NOT contain require() statements with relative paths like '../Actionable'
2. THE codebase SHALL NOT contain require() statements without the LuaBots. prefix for LuaBots modules
3. THE Test_File SHALL NOT contain setup_package_aliases() functions after cleanup
4. WHEN a file previously used package.path modifications, THE file SHALL use standard require() statements after cleanup
5. THE codebase SHALL use consistent module naming conventions across all files

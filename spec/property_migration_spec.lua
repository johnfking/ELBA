--
-- Property-based tests for module structure cleanup migration
-- Feature: module-structure-cleanup
--

local property = require('spec.property')

describe('Module structure cleanup properties', function()
  
  -- **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6, 1.7**
  it('Property 1: File relocation completeness', function()
    -- All migrated files should exist in LuaBots/ and not in root
    local migrated_files = {
      'Actionable.lua',
      'mq.lua',
      'mq_stub.lua',
      'events.lua',
      'parser.lua'
    }
    
    for _, filename in ipairs(migrated_files) do
      -- Check file exists in LuaBots/
      local target_path = 'LuaBots/' .. filename
      local target_file = io.open(target_path, 'r')
      assert.is_not_nil(target_file, 
        string.format('File %s should exist in LuaBots/ directory', filename))
      if target_file then
        target_file:close()
      end
      
      -- Check file does NOT exist in root
      local root_file = io.open(filename, 'r')
      assert.is_nil(root_file,
        string.format('File %s should NOT exist in root directory', filename))
      if root_file then
        root_file:close()
      end
    end
  end)
  
  -- **Validates: Requirements 2.7, 8.2**
  it('Property 2: Import prefix consistency', function()
    -- All require() statements for LuaBots modules should use LuaBots. prefix
    local source_files = {
      'init.lua',
      'LuaBots/Actionable.lua',
      'LuaBots/mq.lua',
      'LuaBots/mq_stub.lua',
      'LuaBots/events.lua',
      'LuaBots/parser.lua',
      'LuaBots/CommandBuilder.lua',
      'LuaBots/CommandExecutor.lua',
      'LuaBots/HTTPClient.lua',
      'LuaBots/NameGenerator.lua'
    }
    
    for _, filepath in ipairs(source_files) do
      local file = io.open(filepath, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        
        -- Check for require statements
        for require_stmt in content:gmatch("require%s*%(?['\"]([^'\"]+)['\"]%)?") do
          -- If it's a LuaBots module (not external like 'mq' or enums)
          if require_stmt:match('^LuaBots%.') or 
             require_stmt:match('^enums%.') or
             require_stmt == 'mq' or
             require_stmt == 'spec.property' or
             require_stmt == 'spec.generators' or
             require_stmt == 'spec.test_helpers' or
             require_stmt == 'spec.output_sink' or
             require_stmt == 'spec.package_config' then
            -- These are valid patterns
          elseif require_stmt:match('Actionable') or
                 require_stmt:match('CommandBuilder') or
                 require_stmt:match('CommandExecutor') or
                 require_stmt:match('HTTPClient') or
                 require_stmt:match('NameGenerator') or
                 require_stmt:match('events') or
                 require_stmt:match('parser') or
                 (require_stmt:match('mq') and not require_stmt:match('mq%.')) then
            -- These should have LuaBots. prefix
            assert.is_true(require_stmt:match('^LuaBots%.'),
              string.format('In %s: require("%s") should use LuaBots. prefix', 
                filepath, require_stmt))
          end
        end
      end
    end
  end)
  
  -- **Validates: Requirements 3.1, 3.2, 3.3**
  it('Property 3: Test files use standard imports', function()
    -- Test files should not modify package.path or create package aliases
    -- (except for mq.PackageMan which is test infrastructure)
    
    local test_files = {
      'spec/init_spec.lua',
      'spec/command_builder_spec.lua',
      'spec/command_executor_spec.lua',
      'spec/http_client_spec.lua',
      'spec/name_generator_spec.lua',
      'spec/property_actionable_spec.lua',
      'spec/property_commands_spec.lua',
      'spec/property_enums_spec.lua',
      'spec/property_mq_stub_spec.lua'
    }
    
    for _, filepath in ipairs(test_files) do
      local file = io.open(filepath, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        
        -- Check for package.path modifications
        assert.is_nil(content:match('package%.path%s*='),
          string.format('%s should not modify package.path', filepath))
        
        -- Check for package.preload aliases (except mq.PackageMan and test dependencies)
        for preload_line in content:gmatch('[^\n]*package%.preload%[[^\n]*') do
          -- Allow mq.PackageMan and test dependencies like cjson, socket.http, ltn12
          if not (preload_line:match('mq%.PackageMan') or 
                  preload_line:match('cjson') or
                  preload_line:match('socket%.http') or
                  preload_line:match('ltn12')) then
            error(string.format('%s should not create package.preload aliases for source modules: %s',
              filepath, preload_line))
          end
        end
        
        -- Check that LuaBots modules use LuaBots. prefix
        for require_stmt in content:gmatch("require%s*%(?['\"]([^'\"]+)['\"]%)?") do
          -- Check if this is a LuaBots module that should have the prefix
          local is_luabots_module = (
            require_stmt == 'Actionable' or
            require_stmt == 'CommandBuilder' or
            require_stmt == 'CommandExecutor' or
            require_stmt == 'HTTPClient' or
            require_stmt == 'NameGenerator'
          )
          
          if is_luabots_module then
            error(string.format('In %s: require("%s") should use LuaBots. prefix',
              filepath, require_stmt))
          end
        end
      end
    end
  end)
  
  -- **Validates: Requirements 8.1**
  it('Property 4: No relative path imports', function()
    -- No require() statements should use relative paths like ../ or ./
    
    local all_lua_files = {}
    
    -- Collect all Lua files
    local function collect_lua_files(dir)
      local handle = io.popen('find ' .. dir .. ' -name "*.lua" 2>/dev/null')
      if handle then
        for file in handle:lines() do
          table.insert(all_lua_files, file)
        end
        handle:close()
      end
    end
    
    collect_lua_files('LuaBots')
    collect_lua_files('spec')
    table.insert(all_lua_files, 'init.lua')
    
    for _, filepath in ipairs(all_lua_files) do
      local file = io.open(filepath, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        
        -- Check for relative path patterns in require statements
        for require_stmt in content:gmatch("require%s*%(?['\"]([^'\"]+)['\"]%)?") do
          assert.is_nil(require_stmt:match('%.%./'),
            string.format('In %s: require("%s") should not use relative path ../',
              filepath, require_stmt))
          assert.is_nil(require_stmt:match('^%./'),
            string.format('In %s: require("%s") should not use relative path ./',
              filepath, require_stmt))
        end
      end
    end
  end)
  
  -- **Validates: Requirements 8.3, 8.4**
  it('Property 5: No package alias functions', function()
    -- Test files should not contain setup_package_aliases() functions
    
    local test_files = {}
    local handle = io.popen('find spec -name "*_spec.lua" 2>/dev/null')
    if handle then
      for file in handle:lines() do
        -- Skip the migration test file itself
        if not file:match('property_migration_spec%.lua') then
          table.insert(test_files, file)
        end
      end
      handle:close()
    end
    
    for _, filepath in ipairs(test_files) do
      local file = io.open(filepath, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        
        -- Check for setup_package_aliases function definition (not just the string)
        local function_pattern = 'function%s+setup_package_aliases%s*%('
        assert.is_nil(content:match(function_pattern),
          string.format('%s should not contain setup_package_aliases() function definition',
            filepath))
        
        -- Check for alias() function definitions (common pattern in old code)
        local alias_pattern = 'local%s+function%s+alias%s*%('
        assert.is_nil(content:match(alias_pattern),
          string.format('%s should not contain alias() helper function',
            filepath))
      end
    end
  end)
  
  -- **Validates: Requirements 7.1, 7.5**
  it('Property 6: Module resolution succeeds', function()
    -- All LuaBots modules should load successfully
    
    -- Setup package manager stub for testing
    if not package.preload['mq.PackageMan'] and not package.loaded['mq.PackageMan'] then
      package.preload['mq.PackageMan'] = function()
        return {
          Require = function(_, _, module)
            local ok, mod = pcall(require, module)
            if ok then
              return mod
            end
            error(('Package "%s" is not available.'):format(module), 2)
          end,
        }
      end
    end
    
    local modules = {
      'init',  -- Main LuaBots module
      'LuaBots.Actionable',
      'LuaBots.mq',
      'LuaBots.mq_stub',
      'LuaBots.events',
      'LuaBots.parser',
      'LuaBots.CommandBuilder',
      'LuaBots.CommandExecutor',
      'LuaBots.HTTPClient',
      'LuaBots.NameGenerator'
    }
    
    for _, module_name in ipairs(modules) do
      local success, result = pcall(require, module_name)
      assert.is_true(success,
        string.format('Module "%s" should load successfully. Error: %s',
          module_name, tostring(result)))
      assert.is_not_nil(result,
        string.format('Module "%s" should return a non-nil value', module_name))
    end
  end)
  
  -- **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.5**
  it('Property 7: Backward compatibility preservation', function()
    -- Public API should remain unchanged
    
    -- Setup package manager stub for testing
    if not package.preload['mq.PackageMan'] and not package.loaded['mq.PackageMan'] then
      package.preload['mq.PackageMan'] = function()
        return {
          Require = function(_, _, module)
            local ok, mod = pcall(require, module)
            if ok then
              return mod
            end
            error(('Package "%s" is not available.'):format(module), 2)
          end,
        }
      end
    end
    
    local LuaBots = require('init')
    
    -- Check main module loads
    assert.is_not_nil(LuaBots, 'LuaBots module should load')
    assert.is_table(LuaBots, 'LuaBots should be a table')
    
    -- Check key modules are accessible
    assert.is_not_nil(LuaBots.Actionable, 'LuaBots.Actionable should be accessible')
    assert.is_not_nil(LuaBots.Class, 'LuaBots.Class should be accessible')
    assert.is_not_nil(LuaBots.Race, 'LuaBots.Race should be accessible')
    assert.is_not_nil(LuaBots.Gender, 'LuaBots.Gender should be accessible')
    
    -- Check key functions exist
    assert.is_function(LuaBots.stance, 'LuaBots.stance should be a function')
    assert.is_function(LuaBots.botcreate, 'LuaBots.botcreate should be a function')
    assert.is_function(LuaBots.attack, 'LuaBots.attack should be a function')
    assert.is_function(LuaBots.follow, 'LuaBots.follow should be a function')
  end)
  
  -- **Validates: Requirements 5.1, 5.2, 5.3, 5.4**
  it('Property 8: Test suite completeness', function()
    -- This property is validated by the test suite itself passing
    -- We verify that the test infrastructure is intact
    
    -- Check that property testing framework is available
    local property_module = require('spec.property')
    assert.is_not_nil(property_module, 'Property testing framework should be available')
    assert.is_function(property_module.forall, 'property.forall should be available')
    
    -- Check that generators are available
    local generators = require('spec.generators')
    assert.is_not_nil(generators, 'Test generators should be available')
    
    -- Check that test helpers are available
    local test_helpers = require('spec.test_helpers')
    assert.is_not_nil(test_helpers, 'Test helpers should be available')
    
    -- The actual validation of 558 tests passing is done by running busted
    -- This test confirms the test infrastructure is intact after migration
  end)
  
end)

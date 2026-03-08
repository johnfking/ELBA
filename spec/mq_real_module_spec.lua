--
-- Test for mq.lua real module loading path
-- This test covers the code path where the real mq module is loaded
--

describe('mq.lua real module loading', function()
  it('loads real mq module when available and LUABOTS_STUB_MQ is not set', function()
    -- Mock the real mq module
    package.preload['mq'] = function()
      return {
        cmd = function() end,
        cmdf = function() end,
        delay = function() end,
        event = {},
        _is_real = true
      }
    end
    
    -- Clear the cached mq module
    package.loaded['LuaBots.mq'] = nil
    
    -- Temporarily clear the stub flag by mocking os.getenv
    local original_getenv = os.getenv
    os.getenv = function(var)
      if var == 'LUABOTS_STUB_MQ' then
        return nil  -- Not set, so use_stub will be false
      end
      return original_getenv(var)
    end
    
    -- Load mq.lua - should load the real module
    local mq_module = require('LuaBots.mq')
    
    -- Verify we got the real module
    assert.is_true(mq_module._is_real)
    
    -- Restore state
    os.getenv = original_getenv
    package.preload['mq'] = nil
    package.loaded['LuaBots.mq'] = nil
    package.loaded['mq'] = nil
  end)
  
  it('falls back to stub when real mq module is not available', function()
    -- Clear any mock
    package.preload['mq'] = nil
    package.loaded['mq'] = nil
    package.loaded['LuaBots.mq'] = nil
    
    -- Mock os.getenv to return nil for LUABOTS_STUB_MQ
    local original_getenv = os.getenv
    os.getenv = function(var)
      if var == 'LUABOTS_STUB_MQ' then
        return nil  -- Not set
      end
      return original_getenv(var)
    end
    
    -- Load mq.lua - should fall back to stub since real mq doesn't exist
    local mq_module = require('LuaBots.mq')
    
    -- Verify we got the stub (has enable_capture function)
    assert.is_function(mq_module.enable_capture)
    
    -- Restore state
    os.getenv = original_getenv
    package.loaded['LuaBots.mq'] = nil
  end)
end)

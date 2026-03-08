-- Verification tests for CommandBuilder module (Task 1.2)
-- These tests verify that the four core command builders are correctly implemented

local CommandBuilder = require('LuaBots.CommandBuilder')
local Actionable = require('LuaBots.Actionable')

describe('CommandBuilder Module - Task 1.2 Verification', function()
  
  describe('build_stance', function()
    it('constructs command string without value or actionable', function()
      local cmd = CommandBuilder.build_stance(nil, nil)
      assert.are.equal('/say ^stance', cmd)
    end)
    
    it('constructs command string with value only', function()
      local cmd = CommandBuilder.build_stance('Passive', nil)
      assert.are.equal('/say ^stance Passive', cmd)
    end)
    
    it('constructs command string with actionable only', function()
      local act = Actionable.target()
      local cmd = CommandBuilder.build_stance(nil, act)
      assert.are.equal('/say ^stance target', cmd)
    end)
    
    it('constructs command string with value and actionable', function()
      local act = Actionable.byname('BotName')
      local cmd = CommandBuilder.build_stance('Passive', act)
      assert.are.equal('/say ^stance Passive byname BotName', cmd)
    end)
  end)
  
  describe('build_attack', function()
    it('constructs command string without value or actionable', function()
      local cmd = CommandBuilder.build_attack(nil, nil)
      assert.are.equal('/say ^attack', cmd)
    end)
    
    it('constructs command string with value only', function()
      local cmd = CommandBuilder.build_attack('on', nil)
      assert.are.equal('/say ^attack on', cmd)
    end)
    
    it('constructs command string with actionable only', function()
      local act = Actionable.spawned()
      local cmd = CommandBuilder.build_attack(nil, act)
      assert.are.equal('/say ^attack spawned', cmd)
    end)
    
    it('constructs command string with value and actionable', function()
      local act = Actionable.byname('BotName')
      local cmd = CommandBuilder.build_attack('on', act)
      assert.are.equal('/say ^attack on byname BotName', cmd)
    end)
  end)
  
  describe('build_guard', function()
    it('constructs command string without value or actionable', function()
      local cmd = CommandBuilder.build_guard(nil, nil)
      assert.are.equal('/say ^guard', cmd)
    end)
    
    it('constructs command string with value only', function()
      local cmd = CommandBuilder.build_guard('on', nil)
      assert.are.equal('/say ^guard on', cmd)
    end)
    
    it('constructs command string with actionable only', function()
      local act = Actionable.all()
      local cmd = CommandBuilder.build_guard(nil, act)
      assert.are.equal('/say ^guard all', cmd)
    end)
    
    it('constructs command string with value and actionable', function()
      local act = Actionable.byname('BotName')
      local cmd = CommandBuilder.build_guard('on', act)
      assert.are.equal('/say ^guard on byname BotName', cmd)
    end)
  end)
  
  describe('build_follow', function()
    it('constructs command string without value or actionable', function()
      local cmd = CommandBuilder.build_follow(nil, nil)
      assert.are.equal('/say ^follow', cmd)
    end)
    
    it('constructs command string with value only', function()
      local cmd = CommandBuilder.build_follow('on', nil)
      assert.are.equal('/say ^follow on', cmd)
    end)
    
    it('constructs command string with actionable only', function()
      local act = Actionable.ownergroup()
      local cmd = CommandBuilder.build_follow(nil, act)
      assert.are.equal('/say ^follow ownergroup', cmd)
    end)
    
    it('constructs command string with value and actionable', function()
      local act = Actionable.byname('BotName')
      local cmd = CommandBuilder.build_follow('on', act)
      assert.are.equal('/say ^follow on byname BotName', cmd)
    end)
  end)
  
  describe('Purity verification - no side effects', function()
    it('does not call mq.cmd or mq.cmdf', function()
      -- Track if mq functions are called
      local mq_cmd_called = false
      local mq_cmdf_called = false
      
      -- Mock mq module
      package.loaded['mq'] = {
        cmd = function() mq_cmd_called = true end,
        cmdf = function() mq_cmdf_called = true end
      }
      
      -- Call all builders
      CommandBuilder.build_stance('Passive', nil)
      CommandBuilder.build_attack('on', nil)
      CommandBuilder.build_guard('on', nil)
      CommandBuilder.build_follow('on', nil)
      
      -- Verify no mq calls were made
      assert.is_false(mq_cmd_called, 'build_stance should not call mq.cmd')
      assert.is_false(mq_cmdf_called, 'build_stance should not call mq.cmdf')
      
      -- Clean up
      package.loaded['mq'] = nil
    end)
    
    it('does not modify global state', function()
      -- Capture initial global state
      local initial_io_write = io.write
      local initial_print = print
      
      -- Call all builders
      CommandBuilder.build_stance('Passive', nil)
      CommandBuilder.build_attack('on', nil)
      CommandBuilder.build_guard('on', nil)
      CommandBuilder.build_follow('on', nil)
      
      -- Verify global state unchanged
      assert.are.equal(initial_io_write, io.write, 'io.write should not be modified')
      assert.are.equal(initial_print, print, 'print should not be modified')
    end)
  end)
  
  describe('Idempotence verification', function()
    it('returns identical strings for identical inputs', function()
      local act = Actionable.byname('TestBot')
      
      -- Call each builder multiple times with same inputs
      local stance1 = CommandBuilder.build_stance('Passive', act)
      local stance2 = CommandBuilder.build_stance('Passive', act)
      local stance3 = CommandBuilder.build_stance('Passive', act)
      
      local attack1 = CommandBuilder.build_attack('on', act)
      local attack2 = CommandBuilder.build_attack('on', act)
      
      local guard1 = CommandBuilder.build_guard('on', act)
      local guard2 = CommandBuilder.build_guard('on', act)
      
      local follow1 = CommandBuilder.build_follow('on', act)
      local follow2 = CommandBuilder.build_follow('on', act)
      
      -- Verify all calls return identical strings
      assert.are.equal(stance1, stance2)
      assert.are.equal(stance2, stance3)
      assert.are.equal(attack1, attack2)
      assert.are.equal(guard1, guard2)
      assert.are.equal(follow1, follow2)
    end)
  end)
  
  describe('Command string format verification', function()
    it('all commands match /say ^<command> [params] format', function()
      local act = Actionable.byname('TestBot')
      
      local stance = CommandBuilder.build_stance('Passive', act)
      local attack = CommandBuilder.build_attack('on', act)
      local guard = CommandBuilder.build_guard('on', act)
      local follow = CommandBuilder.build_follow('on', act)
      
      -- Verify format matches /say ^<command> pattern
      assert.is_not_nil(stance:match('^/say %^stance'), 'stance should start with /say ^stance')
      assert.is_not_nil(attack:match('^/say %^attack'), 'attack should start with /say ^attack')
      assert.is_not_nil(guard:match('^/say %^guard'), 'guard should start with /say ^guard')
      assert.is_not_nil(follow:match('^/say %^follow'), 'follow should start with /say ^follow')
    end)
  end)
end)

package.path = './?.lua;./?/init.lua;./?/?.lua;' .. package.path

local property = require('spec.property')
local generators = require('spec.generators')
local mq = require('mq')

local function capture(fn)
  local output = {}
  local orig = io.write
  ---@diagnostic disable-next-line: duplicate-set-field
  io.write = function(str) table.insert(output, str) end
  fn()
  io.write = orig
  return table.concat(output)
end

describe('MQ stub properties', function()
  it('Property 15: MQ stub outputs commands with newlines', function()
    -- Feature: comprehensive-property-based-testing, Property 15
    property.forall(
      { property.string(5, 50) },
      function(command_str)
        local output = capture(function()
          mq.cmd(command_str)
        end)
        assert.equals(command_str .. '\n', output)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 16: MQ cmdf is equivalent to format then cmd', function()
    -- Feature: comprehensive-property-based-testing, Property 16
    property.forall(
      { property.integer(1, 100), property.string(3, 10) },
      function(num, str)
        local format_str = 'test %d %s'
        
        local output_cmdf = capture(function()
          mq.cmdf(format_str, num, str)
        end)
        
        local formatted = string.format(format_str, num, str)
        local output_cmd = capture(function()
          mq.cmd(formatted)
        end)
        
        assert.equals(output_cmd, output_cmdf)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 17: MQ delay completes without error', function()
    -- Feature: comprehensive-property-based-testing, Property 17
    property.forall(
      { property.integer(0, 10000) },
      function(delay_ms)
        assert.has_no_errors(function()
          mq.delay(delay_ms)
        end)
      end,
      { iterations = 20 }
    )
  end)

  it('Property 18: MQ event registration stores callbacks', function()
    -- Feature: comprehensive-property-based-testing, Property 18
    property.forall(
      { property.string(5, 20) },
      function(event_name)
        local callback = function() end
        mq.event:register(event_name, callback)
        assert.equals(callback, mq.event._handlers[event_name])
      end,
      { iterations = 20 }
    )
  end)

  it('Property 19: MQ event triggers invoke callbacks', function()
    -- Feature: comprehensive-property-based-testing, Property 19
    property.forall(
      { property.string(5, 20), property.integer(1, 100) },
      function(event_name, test_value)
        local received_value = nil
        local callback = function(val)
          received_value = val
        end
        
        mq.event:register(event_name, callback)
        mq.event:trigger(event_name, test_value)
        
        assert.equals(test_value, received_value)
        
        -- Clean up
        mq.event:unregister(event_name)
      end,
      { iterations = 20 }
    )
  end)
end)

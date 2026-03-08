local property = require('spec.property')
local generators = require('spec.generators')
local Actionable = require('LuaBots.Actionable')

describe('Actionable properties', function()
  it('Property 1: types requiring selectors error without them', function()
    -- Feature: comprehensive-property-based-testing, Property 1
    property.forall(
      { generators.actionable_type_requiring_selector() },
      function(actionable_type)
        assert.has_error(function()
          Actionable.new(actionable_type, nil)
        end)
      end,
      { iterations = 100 }
    )
  end)

  it('Property 2: types not requiring selectors error with them', function()
    -- Feature: comprehensive-property-based-testing, Property 2
    property.forall(
      { generators.actionable_type_not_requiring_selector(), generators.selector_string() },
      function(actionable_type, selector)
        -- Only test with non-empty selectors
        if selector ~= '' then
          assert.has_error(function()
            Actionable.new(actionable_type, selector)
          end)
        end
      end,
      { iterations = 100 }
    )
  end)
end)

  it('Property 3: valid combinations create instances', function()
    -- Feature: comprehensive-property-based-testing, Property 3
    property.forall(
      { generators.any_actionable() },
      function(actionable)
        assert.is_not_nil(actionable)
        assert.is_table(actionable)
      end,
      { iterations = 100 }
    )
  end)

  it('Property 4: Actionable tostring format correctness', function()
    -- Feature: comprehensive-property-based-testing, Property 4
    property.forall(
      { generators.any_actionable() },
      function(actionable)
        local str = tostring(actionable)
        assert.is_string(str)
        assert.is_true(#str > 0)
        -- Should contain the actionable type
        assert.is_true(str:find(actionable.type) ~= nil)
        -- If selector exists, should contain it
        if actionable.selector then
          assert.is_true(str:find(actionable.selector, 1, true) ~= nil)
        end
      end,
      { iterations = 100 }
    )
  end)

  it('Property 12: invalid actionable types raise errors', function()
    -- Feature: comprehensive-property-based-testing, Property 12
    property.forall(
      { property.string(5, 20) },
      function(invalid_type)
        -- Make sure it's not a valid type
        if not Actionable.ActionableType[invalid_type] then
          assert.has_error(function()
            Actionable.new(invalid_type)
          end)
        end
      end,
      { iterations = 50 }
    )
  end)

  it('Property 13: long selectors are accepted', function()
    -- Feature: comprehensive-property-based-testing, Property 13
    property.forall(
      { generators.actionable_type_requiring_selector(), property.string(100, 1000) },
      function(actionable_type, long_selector)
        local actionable = Actionable.new(actionable_type, long_selector)
        assert.is_not_nil(actionable)
        assert.equals(long_selector, actionable.selector)
      end,
      { iterations = 50 }
    )
  end)

  it('Property 14: special characters in selectors are accepted', function()
    -- Feature: comprehensive-property-based-testing, Property 14
    property.forall(
      { generators.actionable_type_requiring_selector() },
      function(actionable_type)
        local special_chars = {'test bot', 'bot!@#', 'bot_123', 'bot-name', 'bot.name'}
        for _, selector in ipairs(special_chars) do
          local actionable = Actionable.new(actionable_type, selector)
          assert.is_not_nil(actionable)
          assert.equals(selector, actionable.selector)
        end
      end,
      { iterations = 20 }
    )
  end)

  it('Property 23: RequiresSelector table matches behavior', function()
    -- Feature: comprehensive-property-based-testing, Property 23
    for actionable_type, requires in pairs(Actionable.RequiresSelector) do
      if requires then
        -- Should error without selector
        assert.has_error(function()
          Actionable.new(actionable_type, nil)
        end)
      end
    end
    
    for actionable_type, _ in pairs(Actionable.ActionableType) do
      if not Actionable.RequiresSelector[actionable_type] then
        -- Should error with selector
        assert.has_error(function()
          Actionable.new(actionable_type, 'selector')
        end)
      end
    end
  end)

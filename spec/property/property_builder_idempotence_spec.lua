--
-- Property tests for Command Builder Idempotence
-- Feature: functional-refactoring
-- Task 1.4: Write property tests for command builder idempotence
--

describe("Command Builder Idempotence", function()
  local property = require('spec.property')
  local generators = require('spec.generators')
  local CommandBuilder = require('LuaBots.CommandBuilder')

  describe("Property 2: Command Builder Idempotence", function()
    it("should return identical outputs for same inputs across multiple calls", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.string_parameter(),  -- value parameter
          generators.any_actionable()     -- actionable parameter
        },
        function(value, act)
          -- Test single-parameter builders
          local builders = {
            CommandBuilder.build_stance,
            CommandBuilder.build_attack,
            CommandBuilder.build_guard,
            CommandBuilder.build_follow,
            CommandBuilder.build_hold,
            CommandBuilder.build_cast,
            CommandBuilder.build_taunt,
            CommandBuilder.build_defensive,
            CommandBuilder.build_discipline,
            CommandBuilder.build_charm,
            CommandBuilder.build_cure
          }

          for _, builder in ipairs(builders) do
            -- Call builder multiple times with same inputs
            local result1 = builder(value, act)
            local result2 = builder(value, act)
            local result3 = builder(value, act)

            -- Verify all results are identical
            assert.equals(result1, result2,
              "Builder should return identical output on second call")
            assert.equals(result1, result3,
              "Builder should return identical output on third call")
            assert.equals(result2, result3,
              "Builder should return identical output across all calls")
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent for botcreate builder", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.bot_name(),
          generators.class_value(),
          generators.race_value(),
          generators.gender_value()
        },
        function(name, class, race, gender)
          -- Call botcreate builder multiple times
          local result1 = CommandBuilder.build_botcreate(name, class, race, gender)
          local result2 = CommandBuilder.build_botcreate(name, class, race, gender)
          local result3 = CommandBuilder.build_botcreate(name, class, race, gender)

          -- Verify all results are identical
          assert.equals(result1, result2,
            "build_botcreate should return identical output on second call")
          assert.equals(result1, result3,
            "build_botcreate should return identical output on third call")
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent for multi-parameter builders", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.numeric_parameter(),
          generators.any_actionable()
        },
        function(val1, val2, val3, act)
          -- Test botdyearmor builder (4 numeric params + actionable)
          local result1 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)
          local result2 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)
          local result3 = CommandBuilder.build_botdyearmor(val1, val2, val3, 100, act)

          assert.equals(result1, result2,
            "build_botdyearmor should return identical output on second call")
          assert.equals(result1, result3,
            "build_botdyearmor should return identical output on third call")

          -- Test spelldelays builder (2 numeric params + actionable)
          local result4 = CommandBuilder.build_spelldelays(val1, val2, act)
          local result5 = CommandBuilder.build_spelldelays(val1, val2, act)
          local result6 = CommandBuilder.build_spelldelays(val1, val2, act)

          assert.equals(result4, result5,
            "build_spelldelays should return identical output on second call")
          assert.equals(result4, result6,
            "build_spelldelays should return identical output on third call")
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent with nil parameters", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.any_actionable()
        },
        function(act)
          -- Test builders with nil value parameter
          local builders = {
            CommandBuilder.build_stance,
            CommandBuilder.build_attack,
            CommandBuilder.build_guard,
            CommandBuilder.build_follow
          }

          for _, builder in ipairs(builders) do
            -- Call with nil value multiple times
            local result1 = builder(nil, act)
            local result2 = builder(nil, act)
            local result3 = builder(nil, act)

            assert.equals(result1, result2,
              "Builder with nil value should return identical output on second call")
            assert.equals(result1, result3,
              "Builder with nil value should return identical output on third call")
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent with nil actionable", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.string_parameter()
        },
        function(value)
          -- Test builders with nil actionable
          local builders = {
            CommandBuilder.build_stance,
            CommandBuilder.build_attack,
            CommandBuilder.build_guard,
            CommandBuilder.build_follow,
            CommandBuilder.build_hold,
            CommandBuilder.build_release
          }

          for _, builder in ipairs(builders) do
            -- Call with nil actionable multiple times
            local result1 = builder(value, nil)
            local result2 = builder(value, nil)
            local result3 = builder(value, nil)

            assert.equals(result1, result2,
              "Builder with nil actionable should return identical output on second call")
            assert.equals(result1, result3,
              "Builder with nil actionable should return identical output on third call")
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should be idempotent with both parameters nil", function()
      -- **Validates: Requirements 8.2**

      -- Test builders with both parameters nil
      local builders = {
        CommandBuilder.build_stance,
        CommandBuilder.build_attack,
        CommandBuilder.build_guard,
        CommandBuilder.build_follow,
        CommandBuilder.build_hold,
        CommandBuilder.build_cast,
        CommandBuilder.build_taunt
      }

      for _, builder in ipairs(builders) do
        -- Call with both nil multiple times
        local result1 = builder(nil, nil)
        local result2 = builder(nil, nil)
        local result3 = builder(nil, nil)

        assert.equals(result1, result2,
          "Builder with nil parameters should return identical output on second call")
        assert.equals(result1, result3,
          "Builder with nil parameters should return identical output on third call")
      end
    end)

    it("should be idempotent across all builder functions", function()
      -- **Validates: Requirements 8.2**

      property.forall(
        {
          generators.string_parameter(),
          generators.any_actionable()
        },
        function(value, act)
          -- Test a comprehensive set of builders
          local builders = {
            CommandBuilder.build_stance,
            CommandBuilder.build_attack,
            CommandBuilder.build_guard,
            CommandBuilder.build_follow,
            CommandBuilder.build_hold,
            CommandBuilder.build_release,
            CommandBuilder.build_taunt,
            CommandBuilder.build_charm,
            CommandBuilder.build_cure,
            CommandBuilder.build_defensive,
            CommandBuilder.build_discipline,
            CommandBuilder.build_cast,
            CommandBuilder.build_pull,
            CommandBuilder.build_camp,
            CommandBuilder.build_behindmob,
            CommandBuilder.build_circle,
            CommandBuilder.build_depart,
            CommandBuilder.build_escape
          }

          for _, builder in ipairs(builders) do
            -- Call each builder 5 times to thoroughly test idempotence
            local results = {}
            for i = 1, 5 do
              results[i] = builder(value, act)
            end

            -- Verify all results are identical
            for i = 2, 5 do
              assert.equals(results[1], results[i],
                string.format("Builder should return identical output on call %d", i))
            end
          end
        end,
        { iterations = 100 }
      )
    end)
  end)
end)

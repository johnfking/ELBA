--
-- Property tests for Concurrent Capture Independence
-- Feature: functional-refactoring
-- Task 7.5: Write property tests for concurrent capture independence
--

describe("Concurrent Capture Independence", function()
  local property = require('spec.property')
  local test_helpers = require('spec.test_helpers')
  local output_sink = require('spec.output_sink')

  describe("Property 9: Concurrent Capture Independence", function()
    it("should maintain separate buffers for multiple independent sinks", function()
      -- **Validates: Requirements 3.4**
      -- Property 9: For any set of concurrent capture operations (or captures that
      -- create multiple sinks), each capture should maintain its own buffer without
      -- interference from other captures.

      property.forall(
        {
          property.string(5, 30),  -- text for first sink
          property.string(5, 30),  -- text for second sink
          property.string(5, 30)   -- text for third sink
        },
        function(text1, text2, text3)
          -- Create multiple independent sinks
          local sink1 = output_sink.create_buffer_sink()
          local sink2 = output_sink.create_buffer_sink()
          local sink3 = output_sink.create_buffer_sink()

          -- Write to each sink independently
          sink1:write(text1)
          sink2:write(text2)
          sink3:write(text3)

          -- Verify each sink maintains its own buffer without interference
          assert.equals(text1, sink1:get_output(),
            "Sink1 should only contain text1")
          assert.equals(text2, sink2:get_output(),
            "Sink2 should only contain text2")
          assert.equals(text3, sink3:get_output(),
            "Sink3 should only contain text3")

          -- Write more to each sink to verify continued independence
          sink1:write(text1)
          sink2:write(text2)
          sink3:write(text3)

          -- Verify buffers accumulated independently
          assert.equals(text1 .. text1, sink1:get_output(),
            "Sink1 should have accumulated text1 twice")
          assert.equals(text2 .. text2, sink2:get_output(),
            "Sink2 should have accumulated text2 twice")
          assert.equals(text3 .. text3, sink3:get_output(),
            "Sink3 should have accumulated text3 twice")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence across multiple capture operations", function()
      -- **Validates: Requirements 3.4**
      -- Test that multiple capture operations with different sinks maintain independence

      property.forall(
        {
          property.string(5, 25),
          property.string(5, 25),
          property.string(5, 25),
          property.integer(1, 5)  -- number of writes per capture
        },
        function(text1, text2, text3, num_writes)
          -- Create independent sinks for each capture
          local sink1 = output_sink.create_buffer_sink()
          local sink2 = output_sink.create_buffer_sink()
          local sink3 = output_sink.create_buffer_sink()

          -- Perform first capture
          local captured1 = test_helpers.capture(function()
            for _ = 1, num_writes do
              io.write(text1)
            end
          end, sink1)

          -- Perform second capture
          local captured2 = test_helpers.capture(function()
            for _ = 1, num_writes do
              io.write(text2)
            end
          end, sink2)

          -- Perform third capture
          local captured3 = test_helpers.capture(function()
            for _ = 1, num_writes do
              io.write(text3)
            end
          end, sink3)

          -- Build expected outputs
          local expected1 = string.rep(text1, num_writes)
          local expected2 = string.rep(text2, num_writes)
          local expected3 = string.rep(text3, num_writes)

          -- Verify each capture maintained its own buffer
          assert.equals(expected1, captured1,
            "First capture should only contain text1")
          assert.equals(expected2, captured2,
            "Second capture should only contain text2")
          assert.equals(expected3, captured3,
            "Third capture should only contain text3")

          -- Verify sinks maintained independence
          assert.equals(expected1, sink1:get_output(),
            "Sink1 should only contain text1")
          assert.equals(expected2, sink2:get_output(),
            "Sink2 should only contain text2")
          assert.equals(expected3, sink3:get_output(),
            "Sink3 should only contain text3")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence when sinks are created and used interleaved", function()
      -- **Validates: Requirements 3.4**
      -- Test that interleaved sink creation and usage maintains independence

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20),
          property.string(5, 20)
        },
        function(text1, text2, text3)
          -- Create first sink and write to it
          local sink1 = output_sink.create_buffer_sink()
          sink1:write(text1)

          -- Create second sink and write to it
          local sink2 = output_sink.create_buffer_sink()
          sink2:write(text2)

          -- Write more to first sink
          sink1:write(text1)

          -- Create third sink and write to it
          local sink3 = output_sink.create_buffer_sink()
          sink3:write(text3)

          -- Write more to second sink
          sink2:write(text2)

          -- Write more to third sink
          sink3:write(text3)

          -- Verify each sink maintained its own independent buffer
          assert.equals(text1 .. text1, sink1:get_output(),
            "Sink1 should have text1 twice despite interleaved operations")
          assert.equals(text2 .. text2, sink2:get_output(),
            "Sink2 should have text2 twice despite interleaved operations")
          assert.equals(text3 .. text3, sink3:get_output(),
            "Sink3 should have text3 twice despite interleaved operations")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence with many concurrent sinks", function()
      -- **Validates: Requirements 3.4**
      -- Test independence with a larger number of sinks

      property.forall(
        {
          property.integer(5, 15),  -- number of sinks to create
          property.string(3, 15)    -- base text
        },
        function(num_sinks, base_text)
          -- Create multiple sinks
          local sinks = {}
          for i = 1, num_sinks do
            sinks[i] = output_sink.create_buffer_sink()
          end

          -- Write unique text to each sink
          for i = 1, num_sinks do
            local unique_text = base_text .. tostring(i)
            sinks[i]:write(unique_text)
          end

          -- Verify each sink has only its own unique text
          for i = 1, num_sinks do
            local expected = base_text .. tostring(i)
            assert.equals(expected, sinks[i]:get_output(),
              string.format("Sink %d should only contain its unique text", i))
          end

          -- Write again to all sinks
          for i = 1, num_sinks do
            local unique_text = base_text .. tostring(i)
            sinks[i]:write(unique_text)
          end

          -- Verify each sink accumulated independently
          for i = 1, num_sinks do
            local expected = string.rep(base_text .. tostring(i), 2)
            assert.equals(expected, sinks[i]:get_output(),
              string.format("Sink %d should have accumulated its text twice", i))
          end
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence when sinks are used in nested contexts", function()
      -- **Validates: Requirements 3.4**
      -- Test that nested capture operations maintain buffer independence

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20),
          property.string(5, 20)
        },
        function(outer_text, middle_text, inner_text)
          -- Create sinks for nested captures
          local outer_sink = output_sink.create_buffer_sink()
          local middle_sink = output_sink.create_buffer_sink()
          local inner_sink = output_sink.create_buffer_sink()

          -- Outer capture
          local captured_outer = test_helpers.capture(function()
            io.write(outer_text)

            -- Middle capture (nested in outer)
            local captured_middle = test_helpers.capture(function()
              io.write(middle_text)

              -- Inner capture (nested in middle)
              local captured_inner = test_helpers.capture(function()
                io.write(inner_text)
              end, inner_sink)

              -- Verify inner capture
              assert.equals(inner_text, captured_inner,
                "Inner capture should only have inner_text")

              io.write(middle_text)
            end, middle_sink)

            -- Verify middle capture
            assert.equals(middle_text .. middle_text, captured_middle,
              "Middle capture should only have middle_text twice")

            io.write(outer_text)
          end, outer_sink)

          -- Verify outer capture
          assert.equals(outer_text .. outer_text, captured_outer,
            "Outer capture should only have outer_text twice")

          -- Verify all sinks maintained independence
          assert.equals(outer_text .. outer_text, outer_sink:get_output(),
            "Outer sink should only contain outer_text")
          assert.equals(middle_text .. middle_text, middle_sink:get_output(),
            "Middle sink should only contain middle_text")
          assert.equals(inner_text, inner_sink:get_output(),
            "Inner sink should only contain inner_text")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence when one sink errors", function()
      -- **Validates: Requirements 3.4**
      -- Test that an error in one capture doesn't affect other sinks

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20),
          property.string(5, 20)
        },
        function(text1, text2, text3)
          -- Create independent sinks
          local sink1 = output_sink.create_buffer_sink()
          local sink2 = output_sink.create_buffer_sink()
          local sink3 = output_sink.create_buffer_sink()

          -- First capture (successful)
          local captured1 = test_helpers.capture(function()
            io.write(text1)
          end, sink1)

          -- Second capture (will error)
          local success2, err2 = pcall(function()
            test_helpers.capture(function()
              io.write(text2)
              error("intentional error")
            end, sink2)
          end)

          -- Third capture (successful)
          local captured3 = test_helpers.capture(function()
            io.write(text3)
          end, sink3)

          -- Verify second capture errored
          assert.is_false(success2, "Second capture should have errored")
          assert.is_not_nil(err2, "Error should be propagated")

          -- Verify first and third captures were not affected
          assert.equals(text1, captured1,
            "First capture should not be affected by second capture's error")
          assert.equals(text3, captured3,
            "Third capture should not be affected by second capture's error")

          -- Verify all sinks maintained independence
          assert.equals(text1, sink1:get_output(),
            "Sink1 should only contain text1")
          assert.equals(text2, sink2:get_output(),
            "Sink2 should contain text2 even though capture errored")
          assert.equals(text3, sink3:get_output(),
            "Sink3 should only contain text3")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain buffer independence with empty and non-empty sinks", function()
      -- **Validates: Requirements 3.4**
      -- Test that empty sinks don't interfere with non-empty ones

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20)
        },
        function(text1, text2)
          -- Create multiple sinks
          local sink1 = output_sink.create_buffer_sink()
          local sink2 = output_sink.create_buffer_sink()
          local sink3 = output_sink.create_buffer_sink()

          -- Write to sink1 and sink3, leave sink2 empty
          sink1:write(text1)
          -- sink2 remains empty
          sink3:write(text2)

          -- Verify independence
          assert.equals(text1, sink1:get_output(),
            "Sink1 should contain text1")
          assert.equals("", sink2:get_output(),
            "Sink2 should be empty")
          assert.equals(text2, sink3:get_output(),
            "Sink3 should contain text2")

          -- Write more to sink1 and sink3
          sink1:write(text1)
          sink3:write(text2)

          -- Verify sink2 is still empty and others accumulated
          assert.equals(text1 .. text1, sink1:get_output(),
            "Sink1 should have accumulated text1 twice")
          assert.equals("", sink2:get_output(),
            "Sink2 should still be empty")
          assert.equals(text2 .. text2, sink3:get_output(),
            "Sink3 should have accumulated text2 twice")
        end,
        { iterations = 100 }
      )
    end)
  end)
end)

--
-- Property tests for Output Capture Isolation
-- Feature: functional-refactoring
-- Task 7.3: Write property tests for output capture isolation
--

describe("Output Capture Isolation", function()
  local property = require('spec.property')
  local test_helpers = require('spec.test_helpers')
  local output_sink = require('spec.output_sink')

  describe("Property 7: Output Capture Isolation", function()
    it("should redirect all output to the provided sink", function()
      -- **Validates: Requirements 3.2**
      -- Property 7: For any function that produces output, capturing its output
      -- using the capture helper should redirect all output to the provided sink
      -- and not to stdout.

      property.forall(
        {
          property.string(5, 50),  -- output text
          property.integer(1, 10)  -- number of write calls
        },
        function(text, num_writes)
          -- Create a custom sink to capture output
          local custom_sink = output_sink.create_buffer_sink()

          -- Track if io.write was replaced during capture
          local io_write_before = io.write

          -- Capture output from a function that writes multiple times
          local captured = test_helpers.capture(function()
            -- Verify io.write was replaced (not the original)
            assert.is_not_equal(io_write_before, io.write,
              "io.write should be replaced during capture")

            for i = 1, num_writes do
              io.write(text)
            end
          end, custom_sink)

          -- Verify io.write was restored after capture
          assert.equals(io_write_before, io.write,
            "io.write should be restored after capture")

          -- Verify output was captured in the sink
          local expected_output = string.rep(text, num_writes)
          assert.equals(expected_output, captured,
            "Captured output should match expected output")

          -- Verify the sink contains the output
          assert.equals(expected_output, custom_sink:get_output(),
            "Sink should contain all captured output")
        end,
        { iterations = 100 }
      )
    end)

    it("should isolate output from stdout for various output patterns", function()
      -- **Validates: Requirements 3.2**
      -- Test with different output patterns to ensure isolation

      property.forall(
        {
          property.string(1, 30),
          property.string(1, 30),
          property.string(1, 30)
        },
        function(text1, text2, text3)
          local custom_sink = output_sink.create_buffer_sink()

          -- Track that io.write is replaced
          local io_write_before = io.write

          -- Capture output with multiple different writes
          local captured = test_helpers.capture(function()
            -- Verify io.write was replaced
            assert.is_not_equal(io_write_before, io.write,
              "io.write should be replaced during capture")

            io.write(text1)
            io.write(text2)
            io.write(text3)
          end, custom_sink)

          -- Verify io.write was restored
          assert.equals(io_write_before, io.write,
            "io.write should be restored after capture")

          -- Verify all output was captured
          local expected = text1 .. text2 .. text3
          assert.equals(expected, captured,
            "All output should be captured")

          -- Verify the sink has all the output
          assert.equals(expected, custom_sink:get_output(),
            "Sink should contain all output")
        end,
        { iterations = 100 }
      )
    end)

    it("should redirect output to sink without affecting stdout for empty output", function()
      -- **Validates: Requirements 3.2**
      -- Edge case: function that produces no output

      local custom_sink = output_sink.create_buffer_sink()

      -- Track io.write
      local io_write_before = io.write

      -- Capture from a function that produces no output
      local captured = test_helpers.capture(function()
        -- Verify io.write was replaced
        assert.is_not_equal(io_write_before, io.write,
          "io.write should be replaced during capture")
        -- No output
      end, custom_sink)

      -- Verify io.write was restored
      assert.equals(io_write_before, io.write,
        "io.write should be restored after capture")

      -- Verify no output was captured
      assert.equals("", captured, "Captured output should be empty")

      -- Verify sink is empty
      assert.equals("", custom_sink:get_output(),
        "Sink should be empty when no output is produced")
    end)

    it("should redirect output to default buffer sink when no sink provided", function()
      -- **Validates: Requirements 3.2**
      -- Test that capture works without explicit sink parameter

      property.forall(
        {
          property.string(5, 40)
        },
        function(text)
          -- Track io.write
          local io_write_before = io.write

          -- Capture without providing a sink (should create default buffer sink)
          local captured = test_helpers.capture(function()
            -- Verify io.write was replaced
            assert.is_not_equal(io_write_before, io.write,
              "io.write should be replaced during capture")

            io.write(text)
          end)

          -- Verify io.write was restored
          assert.equals(io_write_before, io.write,
            "io.write should be restored after capture")

          -- Verify output was captured
          assert.equals(text, captured,
            "Output should be captured with default sink")
        end,
        { iterations = 100 }
      )
    end)

    it("should isolate output for functions with complex output patterns", function()
      -- **Validates: Requirements 3.2**
      -- Test with newlines, special characters, and mixed content

      property.forall(
        {
          property.string(5, 20),
          property.integer(1, 5)
        },
        function(base_text, num_lines)
          local custom_sink = output_sink.create_buffer_sink()

          -- Track io.write
          local io_write_before = io.write

          -- Build expected output with newlines
          local expected_parts = {}
          for i = 1, num_lines do
            table.insert(expected_parts, base_text .. tostring(i) .. "\n")
          end
          local expected = table.concat(expected_parts)

          -- Capture output with newlines
          local captured = test_helpers.capture(function()
            -- Verify io.write was replaced
            assert.is_not_equal(io_write_before, io.write,
              "io.write should be replaced during capture")

            for i = 1, num_lines do
              io.write(base_text .. tostring(i) .. "\n")
            end
          end, custom_sink)

          -- Verify io.write was restored
          assert.equals(io_write_before, io.write,
            "io.write should be restored after capture")

          -- Verify output was captured correctly
          assert.equals(expected, captured,
            "Output with newlines should be captured correctly")

          -- Verify sink has the output
          assert.equals(expected, custom_sink:get_output(),
            "Sink should contain all output with newlines")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain isolation across multiple sequential captures", function()
      -- **Validates: Requirements 3.2**
      -- Verify that multiple capture operations maintain isolation

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20),
          property.string(5, 20)
        },
        function(text1, text2, text3)
          -- Track io.write before any captures
          local io_write_original = io.write

          -- First capture
          local sink1 = output_sink.create_buffer_sink()
          local captured1 = test_helpers.capture(function()
            io.write(text1)
          end, sink1)

          -- Verify io.write was restored after first capture
          assert.equals(io_write_original, io.write,
            "io.write should be restored after first capture")

          -- Second capture
          local sink2 = output_sink.create_buffer_sink()
          local captured2 = test_helpers.capture(function()
            io.write(text2)
          end, sink2)

          -- Verify io.write was restored after second capture
          assert.equals(io_write_original, io.write,
            "io.write should be restored after second capture")

          -- Third capture
          local sink3 = output_sink.create_buffer_sink()
          local captured3 = test_helpers.capture(function()
            io.write(text3)
          end, sink3)

          -- Verify io.write was restored after third capture
          assert.equals(io_write_original, io.write,
            "io.write should be restored after third capture")

          -- Verify each capture got the correct output
          assert.equals(text1, captured1, "First capture should match text1")
          assert.equals(text2, captured2, "Second capture should match text2")
          assert.equals(text3, captured3, "Third capture should match text3")

          -- Verify each sink has only its own output
          assert.equals(text1, sink1:get_output(), "Sink1 should only have text1")
          assert.equals(text2, sink2:get_output(), "Sink2 should only have text2")
          assert.equals(text3, sink3:get_output(), "Sink3 should only have text3")
        end,
        { iterations = 100 }
      )
    end)

    it("should isolate output even when function throws an error", function()
      -- **Validates: Requirements 3.2**
      -- Verify isolation is maintained even when captured function errors

      property.forall(
        {
          property.string(5, 20)
        },
        function(text)
          local custom_sink = output_sink.create_buffer_sink()

          -- Track io.write
          local io_write_before = io.write

          -- Capture from a function that writes then errors
          local success, err = pcall(function()
            test_helpers.capture(function()
              io.write(text)
              error("intentional error")
            end, custom_sink)
          end)

          -- Verify io.write was restored even after error
          assert.equals(io_write_before, io.write,
            "io.write should be restored even when function errors")

          -- Verify the function errored as expected
          assert.is_false(success, "Function should have errored")
          assert.is_not_nil(err, "Error should be propagated")

          -- Verify output was still captured before the error
          assert.equals(text, custom_sink:get_output(),
            "Output should be captured even when function errors")
        end,
        { iterations = 100 }
      )
    end)
  end)

  describe("Property 8: Output Capture Restoration", function()
    it("should restore io.write to its exact original value after successful capture", function()
      -- **Validates: Requirements 3.3**
      -- Property 8: For any capture operation, after capture completes,
      -- io.write should be restored to its original value (round-trip property).

      property.forall(
        {
          property.string(5, 50),  -- output text
          property.integer(1, 10)  -- number of write calls
        },
        function(text, num_writes)
          -- Save the original io.write reference before any capture
          local original_io_write = io.write

          -- Create a custom sink
          local custom_sink = output_sink.create_buffer_sink()

          -- Perform capture operation
          test_helpers.capture(function()
            for _ = 1, num_writes do
              io.write(text)
            end
          end, custom_sink)

          -- Verify io.write is restored to the exact original reference
          assert.equals(original_io_write, io.write,
            "io.write should be restored to its exact original value after capture")

          -- Verify the original io.write is still functional
          -- (This tests that we didn't just restore a reference, but the actual function)
          assert.is_function(io.write, "io.write should still be a function")
        end,
        { iterations = 100 }
      )
    end)

    it("should restore io.write even when the captured function throws an error", function()
      -- **Validates: Requirements 3.3**
      -- Round-trip property must hold even in error cases

      property.forall(
        {
          property.string(5, 30),
          property.string(5, 30)  -- error message
        },
        function(text, error_msg)
          -- Save the original io.write reference
          local original_io_write = io.write

          -- Create a custom sink
          local custom_sink = output_sink.create_buffer_sink()

          -- Attempt capture with a function that errors
          local success, err = pcall(function()
            test_helpers.capture(function()
              io.write(text)
              error(error_msg)
            end, custom_sink)
          end)

          -- Verify the function errored as expected
          assert.is_false(success, "Function should have thrown an error")
          assert.is_not_nil(err, "Error should be propagated")

          -- Verify io.write is restored to the exact original reference even after error
          assert.equals(original_io_write, io.write,
            "io.write should be restored to its exact original value even when function errors")

          -- Verify the original io.write is still functional
          assert.is_function(io.write, "io.write should still be a function after error")
        end,
        { iterations = 100 }
      )
    end)

    it("should maintain io.write restoration across multiple sequential captures", function()
      -- **Validates: Requirements 3.3**
      -- Round-trip property should hold across multiple capture operations

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20),
          property.string(5, 20)
        },
        function(text1, text2, text3)
          -- Save the original io.write reference before any captures
          local original_io_write = io.write

          -- First capture
          local sink1 = output_sink.create_buffer_sink()
          test_helpers.capture(function()
            io.write(text1)
          end, sink1)

          -- Verify io.write is restored after first capture
          assert.equals(original_io_write, io.write,
            "io.write should be restored to original after first capture")

          -- Second capture
          local sink2 = output_sink.create_buffer_sink()
          test_helpers.capture(function()
            io.write(text2)
          end, sink2)

          -- Verify io.write is still the original after second capture
          assert.equals(original_io_write, io.write,
            "io.write should be restored to original after second capture")

          -- Third capture
          local sink3 = output_sink.create_buffer_sink()
          test_helpers.capture(function()
            io.write(text3)
          end, sink3)

          -- Verify io.write is still the original after third capture
          assert.equals(original_io_write, io.write,
            "io.write should be restored to original after third capture")

          -- Verify all captures worked correctly
          assert.equals(text1, sink1:get_output(), "First capture should have text1")
          assert.equals(text2, sink2:get_output(), "Second capture should have text2")
          assert.equals(text3, sink3:get_output(), "Third capture should have text3")
        end,
        { iterations = 100 }
      )
    end)

    it("should restore io.write when using default buffer sink", function()
      -- **Validates: Requirements 3.3**
      -- Round-trip property should hold even when no explicit sink is provided

      property.forall(
        {
          property.string(5, 40)
        },
        function(text)
          -- Save the original io.write reference
          local original_io_write = io.write

          -- Capture without providing a sink (uses default buffer sink)
          test_helpers.capture(function()
            io.write(text)
          end)

          -- Verify io.write is restored to the exact original reference
          assert.equals(original_io_write, io.write,
            "io.write should be restored to original even with default sink")

          -- Verify the original io.write is still functional
          assert.is_function(io.write, "io.write should still be a function")
        end,
        { iterations = 100 }
      )
    end)

    it("should restore io.write for nested capture operations", function()
      -- **Validates: Requirements 3.3**
      -- Round-trip property should hold even with nested captures

      property.forall(
        {
          property.string(5, 20),
          property.string(5, 20)
        },
        function(outer_text, inner_text)
          -- Save the original io.write reference
          local original_io_write = io.write

          -- Create sinks before captures
          local outer_sink = output_sink.create_buffer_sink()
          local inner_sink = output_sink.create_buffer_sink()

          -- Outer capture
          test_helpers.capture(function()
            io.write(outer_text)

            -- Save io.write at this point (should be the sink's write)
            local outer_capture_io_write = io.write

            -- Inner capture
            test_helpers.capture(function()
              io.write(inner_text)
            end, inner_sink)

            -- After inner capture, io.write should be restored to outer capture's io.write
            assert.equals(outer_capture_io_write, io.write,
              "io.write should be restored to outer capture's io.write after inner capture")

            io.write(outer_text)
          end, outer_sink)

          -- After outer capture, io.write should be restored to the original
          assert.equals(original_io_write, io.write,
            "io.write should be restored to original after nested captures")

          -- Verify captures worked correctly
          assert.equals(outer_text .. outer_text, outer_sink:get_output(),
            "Outer capture should have both outer_text writes")
          assert.equals(inner_text, inner_sink:get_output(),
            "Inner capture should have inner_text")
        end,
        { iterations = 100 }
      )
    end)

    it("should restore io.write when capture is called with empty function", function()
      -- **Validates: Requirements 3.3**
      -- Edge case: round-trip property should hold even for empty functions

      -- Save the original io.write reference
      local original_io_write = io.write

      -- Capture with empty function
      local sink = output_sink.create_buffer_sink()
      test_helpers.capture(function()
        -- No output
      end, sink)

      -- Verify io.write is restored to the exact original reference
      assert.equals(original_io_write, io.write,
        "io.write should be restored to original even for empty function")

      -- Verify the original io.write is still functional
      assert.is_function(io.write, "io.write should still be a function")

      -- Verify no output was captured
      assert.equals("", sink:get_output(), "Sink should be empty")
    end)

    it("should restore io.write to the same reference across different capture scenarios", function()
      -- **Validates: Requirements 3.3**
      -- Comprehensive round-trip test across various scenarios

      property.forall(
        {
          property.string(5, 30),
          property.boolean(),  -- whether to use custom sink
          property.boolean()   -- whether to throw error
        },
        function(text, use_custom_sink, should_error)
          -- Save the original io.write reference
          local original_io_write = io.write

          -- Prepare sink
          local sink = use_custom_sink and output_sink.create_buffer_sink() or nil

          -- Attempt capture
          local success, err = pcall(function()
            test_helpers.capture(function()
              io.write(text)
              if should_error then
                error("test error")
              end
            end, sink)
          end)

          -- Verify error behavior
          if should_error then
            assert.is_false(success, "Function should have errored when should_error is true")
          else
            assert.is_true(success, "Function should not have errored when should_error is false")
          end

          -- Verify io.write is restored to the exact original reference
          -- This is the key round-trip property
          assert.equals(original_io_write, io.write,
            string.format(
              "io.write should be restored to original (custom_sink=%s, error=%s)",
              tostring(use_custom_sink),
              tostring(should_error)
            ))

          -- Verify the original io.write is still functional
          assert.is_function(io.write, "io.write should still be a function")
        end,
        { iterations = 100 }
      )
    end)
  end)
end)

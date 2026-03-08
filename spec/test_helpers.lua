--- Test Helper Functions
--- Provides shared utilities for test files, including output capture
--- This module implements Requirement 3.2 and 3.3 for side-effect-free output capture

local output_sink = require('spec.output_sink')

local M = {}

--- Capture output from a function using OutputSink
--- This function temporarily replaces io.write with a sink, executes the function,
--- and restores io.write even if an error occurs (using pcall for safety).
---
--- @param fn function function to execute and capture output from
--- @param sink OutputSink? optional sink (creates buffer sink if nil)
--- @return string captured output from the function
---
--- Requirements:
--- - 3.2: Redirects output to the provided sink
--- - 3.3: Restores original io.write without side effects
function M.capture(fn, sink)
  -- Create buffer sink if not provided
  sink = sink or output_sink.create_buffer_sink()
  
  -- Save original io.write
  local original_write = io.write
  
  -- Temporarily replace io.write with sink.write
  ---@diagnostic disable-next-line: duplicate-set-field
  io.write = function(text)
    sink:write(text)
  end
  
  -- Execute function with pcall to ensure io.write restoration on error
  local success, err = pcall(fn)
  
  -- Restore original io.write (guaranteed to run even on error)
  io.write = original_write
  
  -- Propagate error if function failed
  if not success then
    error(err, 2)
  end
  
  -- Return captured output
  return sink:get_output()
end

return M

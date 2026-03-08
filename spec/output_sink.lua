---@class OutputSink
---@field write fun(self: OutputSink, text: string): nil
---@field get_output fun(self: OutputSink): string

local M = {}

--- Create an output sink that captures to a buffer
--- This provides a way to capture output without modifying global io.write
---@return OutputSink
function M.create_buffer_sink()
  local buffer = {}
  
  return {
    --- Append text to the buffer
    ---@param self OutputSink
    ---@param text string text to append
    write = function(self, text)
      table.insert(buffer, text)
    end,
    
    --- Retrieve accumulated output from the buffer
    ---@param self OutputSink
    ---@return string accumulated output
    get_output = function(self)
      return table.concat(buffer)
    end
  }
end

return M

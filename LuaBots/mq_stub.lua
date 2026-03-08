-- mq.lua

-- Lightweight stub of the MacroQuest 'mq' library for offline testing.
-- Only implements a few commonly used helpers.

local socket = require('socket')

local M = {}

-- Command capture state
local capture_mode = false
local command_buffer = {}

--- Enable command capture mode
function M.enable_capture()
    capture_mode = true
    command_buffer = {}
end

--- Disable command capture mode
function M.disable_capture()
    capture_mode = false
end

--- Get captured commands
---@return table list of captured command strings
function M.get_captured_commands()
    return command_buffer
end

--- Clear command buffer
function M.clear_captured_commands()
    command_buffer = {}
end

--- Send a command string.
---@param cmd string command to execute
function M.cmd(cmd)
    if capture_mode then
        table.insert(command_buffer, cmd)
    else
        io.write(cmd .. '\n')
    end
end

--- Format the command and print to stdout.
---@param fmt string format string
---@param ... any format arguments
function M.cmdf(fmt, ...)
    -- Handle case where no format arguments provided
    if select('#', ...) == 0 then
        M.cmd(fmt)
    else
        local msg = string.format(fmt, ...)
        M.cmd(msg)
    end
end

--- Simple event dispatcher used for testing.
M.event = {
    _handlers = {},

    --- Register a callback for an event name.
    register = function(self, name, cb)
        self._handlers[name] = cb
    end,

    --- Unregister a callback.
    unregister = function(self, name)
        self._handlers[name] = nil
    end,

    --- Trigger an event (test helper).
    trigger = function(self, name, ...)
        local cb = self._handlers[name]
        if cb then
            cb(...)
        end
    end,
}

--- Pause execution for a number of milliseconds.
---@param ms number milliseconds to wait
function M.delay(ms)
    socket.sleep(ms / 1000)
end

return M

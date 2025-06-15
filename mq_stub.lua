-- mq.lua

-- Lightweight stub of the MacroQuest 'mq' library for offline testing.
-- Only implements a few commonly used helpers.

local socket = require('socket')

local M = {}

--- Send a command string.
-- @param cmd string command to execute
function M.cmd(cmd)
    io.write(cmd .. '\n')
end

-- Format the command and print to stdout.
-- @param fmt string format string
-- @param ... any format arguments
function M.cmdf(fmt, ...)
    local msg = string.format(fmt, ...)
    M.cmd(msg)
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
-- @param ms number milliseconds to wait
function M.delay(ms)
    socket.sleep(ms / 1000)
end

return M

---
--- CommandExecutor Module
---
--- This module handles the side effects of executing bot commands.
--- It provides a thin wrapper around mq.cmd() and mq.cmdf() to separate
--- command execution (side effects) from command construction (pure logic).
---
--- Side Effects:
---   - Calls mq.cmd() which sends commands to MacroQuest
---   - Performs I/O operations (command execution)
---
--- Usage:
---   local CommandExecutor = require('LuaBots.CommandExecutor')
---   local cmd = "/say ^stance Passive"
---   CommandExecutor.execute(cmd)
---
--- @module LuaBots.CommandExecutor

---@class CommandExecutor
local CommandExecutor = {}

--- Execute a command string using mq.cmd
--- 
--- This function performs a side effect by calling mq.cmd() to execute
--- the provided command string in MacroQuest.
---
---@param cmd string command to execute
function CommandExecutor.execute(cmd)
    local mq = require('mq')
    mq.cmd(cmd)
end

--- Execute a formatted command string
--- 
--- This function performs a side effect by calling mq.cmdf() to format
--- and execute a command string in MacroQuest.
---
---@param fmt string format string
---@param ... any format arguments
function CommandExecutor.executef(fmt, ...)
    local mq = require('mq')
    mq.cmdf(fmt, ...)
end

return CommandExecutor

-- events.lua
local mq     = require("elba.mq")
local parser = require("elba.parser")
local M      = {}

--- Register MacroQuest hooks
function M.setup()
    -- mq.event.register("feedback", parser.handleText)
    -- mq.event.register("spawn", parser.handleSpawn)
    -- mq.event.register("link", parser.handleLink)
end

--- Unregister MacroQuest hooks
function M.teardown()
    -- mq.event.unregister("feedback", parser.handleText)
    -- mq.event.unregister("spawn", parser.handleSpawn)
    -- mq.event.unregister("link", parser.handleLink)
end

return M

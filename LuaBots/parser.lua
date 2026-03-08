-- parser.lua
local mq       = require("LuaBots.mq")
local M        = {}

--- Handle incoming text lines
--- @param line string
function M.handleText(line)
    -- TODO: match patterns and accumulate response blocks
end

--- Setup parser event listeners
function M.setup()
    -- mq.event.register("feedback", M.handleText)
end

--- Teardown parser event listeners
function M.teardown()
    -- mq.event.unregister("feedback", M.handleText)
end

return M

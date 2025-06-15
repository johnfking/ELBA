---
--- Actionable.lua — static constructors for each actionable type
---

--- @class Actionable
--- @field type string               actionable token
--- @field selector string?          optional associated selector
local Actionable = {}
Actionable.__index = Actionable

--- @enum (key) ActionableType
Actionable.ActionableType = {
  target                  = "target",
  byname                  = "byname",
  ownergroup              = "ownergroup",
  botgroup                = "botgroup",
  targetgroup             = "targetgroup",
  namesgroup              = "namesgroup",
  healrotation            = "healrotation",
  healrotationmembers     = "healrotationmembers",
  healrotationtargets     = "healrotationtargets",
  spawned                 = "spawned",
  all                     = "all",
}

--- @private
--- @type table<ActionableType, boolean>
Actionable.RequiresSelector = {
  byname              = true,
  botgroup            = true,
  namesgroup          = true,
  healrotation        = true,
  healrotationmembers = true,
  healrotationtargets = true,
}

--- Create a new Actionable.
--- @param actionType ActionableType
--- @param selector   string?
--- @return Actionable
function Actionable.new(actionType, selector)
  assert(
    Actionable.ActionableType[actionType],
    ("Invalid actionable type: %s"):format(tostring(actionType))
  )

  local must = Actionable.RequiresSelector[actionType]
  if must and not selector then
    error(("Actionable type '%s' requires a selector"):format(actionType), 2)
  elseif not must and selector then
    error(("Actionable type '%s' does not accept a selector"):format(actionType), 2)
  end

  return setmetatable({ type = actionType, selector = selector }, Actionable)
end

function Actionable:__tostring()
  if self.selector then
    return ("%s %s"):format(self.type, self.selector)
  end
  return self.type
end

--- Selects target as single bot.
--- @return Actionable
function Actionable.target()
  return Actionable.new(Actionable.ActionableType.target)
end

--- Selects single bot by name.
--- @param name string
--- @return Actionable
function Actionable.byname(name)
  return Actionable.new(Actionable.ActionableType.byname, name)
end

--- Selects all bots in the owner's group.
--- @return Actionable
function Actionable.ownergroup()
  return Actionable.new(Actionable.ActionableType.ownergroup)
end

--- Selects members of a bot-group by its name.
--- @param group string
--- @return Actionable
function Actionable.botgroup(group)
  return Actionable.new(Actionable.ActionableType.botgroup, group)
end

--- Selects all bots in target's group.
--- @return Actionable
function Actionable.targetgroup()
  return Actionable.new(Actionable.ActionableType.targetgroup)
end

--- Selects all bots in name's group.
--- @param group string
--- @return Actionable
function Actionable.namesgroup(group)
  return Actionable.new(Actionable.ActionableType.namesgroup, group)
end

--- Selects all members and targets of a heal rotation.
--- @param name string
--- @return Actionable
function Actionable.healrotation(name)
  return Actionable.new(Actionable.ActionableType.healrotation, name)
end

--- Selects only members of a heal rotation.
--- @param name string
--- @return Actionable
function Actionable.healrotationmembers(name)
  return Actionable.new(Actionable.ActionableType.healrotationmembers, name)
end

--- Selects only targets of a heal rotation.
--- @param name string
--- @return Actionable
function Actionable.healrotationtargets(name)
  return Actionable.new(Actionable.ActionableType.healrotationtargets, name)
end

--- Selects all spawned bots.
--- @return Actionable
function Actionable.spawned()
  return Actionable.new(Actionable.ActionableType.spawned)
end

--- Selects all bots (for bulk updates).
--- @return Actionable
function Actionable.all()
  return Actionable.new(Actionable.ActionableType.all)
end

return Actionable

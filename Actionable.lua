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
  target                  = "target", -- uses the command on the target.  Some commands will default to target if no actionable is selected.
  byname                  = "byname", -- [name] selects a bot by their name
  byclass                 = "byclass", -- [class] selects bots by class
  byrace                  = "byrace", -- [race] selects bots by race
  ownergroup              = "ownergroup", -- selects all the bots in the owner's group
  ownerraid               = "ownerraid", -- selects all the bots in the owner's raid
  targetgroup             = "targetgroup", -- selects all the bots in the target's group
  namesgroup              = "namesgroup", -- [name] selects all the bots in [name's] group
  healrotation            = "healrotation", -- [name] selects all members and target bots of a heal rotation where [name] is a member
  healrotationmembers     = "healrotationmembers", -- [name] selects all members of a heal rotation where [name] is a member
  mmr                     = "mmr", -- selects all bots that are currently at max melee range
  spawned                 = "spawned", -- selects all spawned bots1
  all                     = "all", -- selects all spawned bots
}

--- @private
--- @type table<ActionableType, boolean>
Actionable.RequiresSelector = {
  byname              = true,
  byclass             = true,
  byrace              = true,
  botgroup            = true,
  namesgroup          = true,
  healrotation        = true,
  healrotationmembers = true,
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

-- Selects bots by class.
--- @param class Class | number
--- @return Actionable
function Actionable.byclass(class)
  return Actionable.new(Actionable.ActionableType.byclass, tostring.class)
end

--- Selects bots by race.
--- @param race Race | number
--- @return Actionable
function Actionable.byrace(race)
  return Actionable.new(Actionable.ActionableType.byrace, tostring.race)
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

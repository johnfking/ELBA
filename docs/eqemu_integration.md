# EQEmu bot command integration

This library sits on top of the MacroQuest `/say ^` interface and mirrors the bot command handlers that ship with the EQEmu server.  The notes below summarise how the Lua helpers map to the C++ implementation that lives under `zone/bot_commands` in the [EQEmu/Server](https://github.com/EQEmu/Server) repository.

## Command transport

* `Elba` builds commands with `/say ^<command>` and passes them to MacroQuest through `mq.cmdf`, so every helper ultimately feeds into the same chat-based entry point that the server expects.
* The helper functions forward up to two positional arguments, followed by an optional actionable selector (for example `ownergroup` or `byclass`).

This mirrors what the server side is prepared to parse: each handler receives a `Seperator` (tokenised chat command) and chooses how to interpret `arg[1]`, `arg[2]`, and the actionable tokens.

## Actionable selectors

`Actionable.lua` contains factory helpers for the selectors that the server side recognises.  The names (such as `byname`, `ownergroup`, `healrotation`, and `mmr`) match the tokens that the C++ handlers pass into `ActionableBots::PopulateSBL`, so picking a selector in Lua results in the same subset of bots being queued on the server.

Some selectors (for example `byname`, `byclass`, `byrace`, or any of the heal rotation helpers) require an additional identifier, and the constructor will raise an error if you omit it.  Others (such as `ownergroup` or `spawned`) act as simple flags.

## Cross-reference: Lua helpers and EQEmu handlers

The table below lists a few representative helpers and the handler that processes the command on the server.  Every handler lives under `zone/bot_commands` and begins with `bot_command_`, so locating a command boils down to matching the helper name with its C++ counterpart.

| Lua helper | EQEmu handler | Purpose on the server | Notes on selectors and arguments |
| --- | --- | --- | --- |
| `Elba:attack(value, act)` | `attack.cpp` → `bot_command_attack` | Orders bots to attack the client's current target.  Validates line-of-sight and populates an actionable bot list before toggling the attack state. | Accepts optional actionable tokens (`spawned`, `byclass`, etc.).  Requires an enemy target in range.
| `Elba:botcamp(value, act)` | `bot.cpp` → `bot_command_camp` | Camps the selected bots after ensuring spawn conditions are met. | Allows selectors like `ownergroup`, `byclass`, or `byrace`.  Uses `ActionableBots::PopulateSBL` with the Type1 mask.
| `Elba:behindmob(value, act)` | `behind_mob.cpp` → `bot_command_behind_mob` | Keeps melee bots positioned behind their target. | Defaults to the targeted mob if no selector is supplied.
| `Elba:applypoison(value, act)` | `apply_poison.cpp` → `bot_command_apply_poison` | Consumes poison items from a rogue bot's inventory. | Requires a `byname` selector so the server can look up the owning rogue bot.
| `Elba:applypotion(value, act)` | `apply_potion.cpp` → `bot_command_apply_potion` | Orders caster bots to use a potion item. | Accepts any actionable group; handlers iterate the target list and check inventory slots.
| `Elba:botcreate(name, class, race, gender)` | `name.cpp` / `bot.cpp` | Validates the requested name and class/race combination before spawning or cloning a bot. | ELBA's helper can auto-generate a name (see below) before relaying the command.

> Tip: because the server side uses `helper_command_alias_fail` to normalise aliases, you may encounter commands that accept short-hand names (for example, `/say ^attack` and `/say ^botattack` both reach `bot_command_attack`).  ELBA sticks to the canonical names shown above.

## Auto-generated bot names

When you call `Elba:botcreate("AUTO", class, race, gender)`, the helper queries the Iron Arachne name API to obtain a lore-friendly name that matches the desired race and gender, then forwards the resolved name to `/say ^botcreate`.  The request falls back to standard behaviour if the API cannot be reached.

## Exploring additional handlers

The same pattern extends to the rest of the helpers.  To trace a command end-to-end:

1. Locate the Lua method in `init.lua` and note the command token it sends.
2. In the EQEmu server tree, open `zone/bot_commands/<command>.cpp` to inspect the business logic.
3. Follow any helper calls (such as `ActionableBots::AsTarget_ByBot`, `PopulateSBL`, or `Bot::CheckCreateLimit`) to understand prerequisites and error messages.

Using this approach lets you document or extend new helpers with confidence that the Lua layer mirrors the authoritative server behaviour.

--
-- Name Generator Module
--
-- Generates bot names using an external HTTP API.
-- Supports race and gender-specific name generation.
--

---@class NameGenerator
local NameGenerator = {}

-- Race ID to API race name mapping
local race_map = {
  [1] = "human", [2] = "human", [3] = "human",
  [4] = "elf", [5] = "elf", [6] = "elf",
  [7] = "half-elf", [8] = "dwarf", [9] = "troll",
  [10] = "orc", [11] = "halfling", [12] = "gnome",
  [128] = "dragonborn", [130] = "tiefling",
  [330] = "goblin", [522] = "dragonborn"
}

-- Gender ID to API gender name mapping
local gender_map = { [0] = "male", [1] = "female" }

--- Generate a bot name using HTTP API
--- Makes an HTTP request to the name generation API and returns the first name
--- from the response. Handles errors gracefully by returning nil and an error message.
---@param race number race ID (1-12, 128, 130, 330, 522)
---@param gender number gender ID (0 = male, 1 = female)
---@param http_client HTTPClient HTTP client for making requests
---@return string|nil name generated name or nil on failure
---@return string|nil error error message if failed
function NameGenerator.generate_name(race, gender, http_client)
  -- Map race and gender IDs to API-compatible strings
  local api_race = race_map[race] or "human"
  local api_gender = gender_map[gender] or "male"
  
  -- Construct API URL
  local url = string.format("https://names.ironarachne.com/race/%s/%s/1", api_race, api_gender)
  
  -- Make HTTP request
  local body, code = http_client.request({ url = url })
  
  -- Check HTTP response code
  if code ~= 200 then
    return nil, string.format("HTTP request failed with code %d", code or 0)
  end
  
  -- Parse JSON response
  local json = require('cjson')
  local success, data = pcall(json.decode, body)
  
  if not success then
    return nil, "Failed to parse API response"
  end
  
  -- Extract names array from response
  local names = data["names"]
  
  if type(names) == "table" and #names > 0 then
    return names[1], nil
  else
    return nil, "No valid names in API response"
  end
end

return NameGenerator

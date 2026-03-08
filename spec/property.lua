--
-- Property-based testing framework for Lua
-- Integrates with busted test framework
--

local property = {}

-- Internal RNG state
local rng_seed = tonumber(os.getenv('PROPERTY_SEED')) or os.time()
math.randomseed(rng_seed)

-- Store the seed for reporting
property._seed = rng_seed

--- Generate random integers within a range
---@param min number minimum value (inclusive)
---@param max number maximum value (inclusive)
---@return table generator that produces random integers
function property.integer(min, max)
  assert(type(min) == 'number', 'min must be a number')
  assert(type(max) == 'number', 'max must be a number')
  assert(min <= max, 'min must be less than or equal to max')
  
  return {
    generate = function()
      return math.random(min, max)
    end
  }
end

--- Generate random boolean values
---@return table generator that produces true or false
function property.boolean()
  return {
    generate = function()
      return math.random() < 0.5
    end
  }
end

--- Generate random strings
---@param len_min number minimum length
---@param len_max number maximum length
---@param charset string|nil optional character set (default: alphanumeric)
---@return table generator that produces random strings
function property.string(len_min, len_max, charset)
  assert(type(len_min) == 'number', 'len_min must be a number')
  assert(type(len_max) == 'number', 'len_max must be a number')
  assert(len_min <= len_max, 'len_min must be less than or equal to len_max')
  
  -- Default alphanumeric charset
  local chars = charset or 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  
  return {
    generate = function()
      local length = math.random(len_min, len_max)
      local result = {}
      for i = 1, length do
        local idx = math.random(1, #chars)
        result[i] = chars:sub(idx, idx)
      end
      return table.concat(result)
    end
  }
end

--- Generate random selection from a list
---@param list table list of values to select from
---@return table generator that produces random selections
function property.oneof(list)
  assert(type(list) == 'table', 'list must be a table')
  assert(#list > 0, 'list must not be empty')
  
  return {
    generate = function()
      local idx = math.random(1, #list)
      return list[idx]
    end
  }
end

--- Run a property test with random inputs
---@param generators table list of generators to produce test inputs
---@param test_fn function test function that receives generated values
---@param opts table|nil optional configuration (iterations, seed)
function property.forall(generators, test_fn, opts)
  assert(type(generators) == 'table', 'generators must be a table')
  assert(type(test_fn) == 'function', 'test_fn must be a function')
  
  opts = opts or {}
  local iterations = opts.iterations or 100
  
  for i = 1, iterations do
    -- Generate values from each generator
    local values = {}
    for j, gen in ipairs(generators) do
      assert(type(gen) == 'table' and type(gen.generate) == 'function',
        'generator ' .. j .. ' must have a generate function')
      values[j] = gen.generate()
    end
    
    -- Run the test function with generated values
    local success, err = pcall(test_fn, table.unpack(values))
    
    if not success then
      -- Report the failing input
      local input_str = {}
      for j, val in ipairs(values) do
        input_str[j] = string.format('%q', tostring(val))
      end
      
      error(string.format(
        'Property failed on iteration %d with inputs: [%s]\nError: %s',
        i,
        table.concat(input_str, ', '),
        tostring(err)
      ), 2)
    end
  end
end

--- Generate sample values from a generator for debugging
---@param generator table generator to sample from
---@param count number|nil number of samples to generate (default: 10)
---@return table list of generated sample values
function property.sample(generator, count)
  assert(type(generator) == 'table' and type(generator.generate) == 'function',
    'generator must have a generate function')
  
  count = count or 10
  local samples = {}
  
  for i = 1, count do
    samples[i] = generator.generate()
  end
  
  return samples
end

return property

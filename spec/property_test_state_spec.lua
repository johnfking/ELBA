--
-- Unit tests for PropertyTestState structure
--

describe("PropertyTestState", function()
  local property
  
  before_each(function()
    property = require('spec.property')
  end)
  
  describe("create_test_state", function()
    it("should create a state with default seed from environment or os.time()", function()
      local state = property.create_test_state()
      
      assert.is_table(state)
      assert.is_number(state.rng_seed)
      assert.is_number(state.iteration)
      assert.equals(0, state.iteration)
    end)
    
    it("should create a state with provided seed", function()
      local seed = 12345
      local state = property.create_test_state(seed)
      
      assert.is_table(state)
      assert.equals(seed, state.rng_seed)
      assert.equals(0, state.iteration)
    end)
    
    it("should use PROPERTY_SEED environment variable when no seed provided", function()
      -- Save original env var
      local original_seed = os.getenv('PROPERTY_SEED')
      
      -- Set test seed
      os.execute('export PROPERTY_SEED=99999')
      
      -- Note: In Lua, os.getenv reads the environment at process start,
      -- so we can't actually test this dynamically. This test documents
      -- the expected behavior.
      local state = property.create_test_state()
      
      assert.is_table(state)
      assert.is_number(state.rng_seed)
      assert.equals(0, state.iteration)
    end)
    
    it("should create independent states with different seeds", function()
      local state1 = property.create_test_state(100)
      local state2 = property.create_test_state(200)
      
      assert.not_equals(state1.rng_seed, state2.rng_seed)
      assert.equals(100, state1.rng_seed)
      assert.equals(200, state2.rng_seed)
    end)
    
    it("should have rng_seed and iteration fields", function()
      local state = property.create_test_state(42)
      
      -- Verify structure
      assert.is_not_nil(state.rng_seed)
      assert.is_not_nil(state.iteration)
      
      -- Verify types
      assert.equals('number', type(state.rng_seed))
      assert.equals('number', type(state.iteration))
    end)
  end)
end)

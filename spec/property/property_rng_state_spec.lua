--
-- Property tests for RNG state management
-- Feature: functional-refactoring
-- Task 6.2: Update property.forall() to accept and return state
--

describe("Property Test Framework - RNG State Management", function()
  local property = require('spec.property')
  
  describe("Task 6.2: State parameter acceptance and return", function()
    it("should accept an optional state parameter", function()
      -- Create a custom state
      local custom_state = property.create_test_state(12345)
      
      -- Run a simple property test with the custom state
      local final_state = property.forall(
        { property.integer(1, 10) },
        function(n)
          assert.is_true(n >= 1 and n <= 10)
        end,
        { iterations = 10 },
        custom_state
      )
      
      -- Verify state was used and returned
      assert.is_not_nil(final_state)
      assert.is_table(final_state)
      assert.is_number(final_state.rng_seed)
      assert.is_number(final_state.iteration)
    end)
    
    it("should create isolated state if not provided", function()
      -- Run without providing state
      local final_state = property.forall(
        { property.integer(1, 10) },
        function(n)
          assert.is_true(n >= 1 and n <= 10)
        end,
        { iterations = 10 }
      )
      
      -- Verify state was created and returned
      assert.is_not_nil(final_state)
      assert.is_table(final_state)
      assert.is_number(final_state.rng_seed)
      assert.is_number(final_state.iteration)
      assert.equals(10, final_state.iteration)
    end)
    
    it("should set math.randomseed from state.rng_seed", function()
      -- Create state with known seed
      local known_seed = 42
      local custom_state = property.create_test_state(known_seed)
      
      -- Capture generated values
      local generated_values = {}
      property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(generated_values, n)
        end,
        { iterations = 5 },
        custom_state
      )
      
      -- Run again with same seed - should produce same sequence
      local custom_state2 = property.create_test_state(known_seed)
      local generated_values2 = {}
      property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(generated_values2, n)
        end,
        { iterations = 5 },
        custom_state2
      )
      
      -- Verify same sequence was generated
      assert.equals(#generated_values, #generated_values2)
      for i = 1, #generated_values do
        assert.equals(generated_values[i], generated_values2[i],
          string.format("Value at index %d should match", i))
      end
    end)
    
    it("should update state.rng_seed after test execution", function()
      local initial_seed = 999
      local custom_state = property.create_test_state(initial_seed)
      
      -- Run property test
      local final_state = property.forall(
        { property.integer(1, 10) },
        function(n)
          assert.is_true(n >= 1 and n <= 10)
        end,
        { iterations = 10 },
        custom_state
      )
      
      -- Verify seed was updated
      assert.is_not_nil(final_state.rng_seed)
      assert.is_not_equal(initial_seed, final_state.rng_seed,
        "RNG seed should be updated after test execution")
    end)
    
    it("should return final state with correct iteration count", function()
      local iterations = 25
      local custom_state = property.create_test_state(123)
      
      local final_state = property.forall(
        { property.integer(1, 10) },
        function(n)
          assert.is_true(n >= 1 and n <= 10)
        end,
        { iterations = iterations },
        custom_state
      )
      
      -- Verify final iteration count
      assert.equals(iterations, final_state.iteration)
    end)
  end)
  
  describe("Requirement 2.2: Use provided RNG state for generation", function()
    it("should use provided state for generation (determinism)", function()
      -- **Validates: Requirements 2.2**
      local seed = 777
      local state1 = property.create_test_state(seed)
      local state2 = property.create_test_state(seed)
      
      local values1 = {}
      property.forall(
        { property.integer(1, 1000), property.string(5, 10) },
        function(n, s)
          table.insert(values1, {n, s})
        end,
        { iterations = 20 },
        state1
      )
      
      local values2 = {}
      property.forall(
        { property.integer(1, 1000), property.string(5, 10) },
        function(n, s)
          table.insert(values2, {n, s})
        end,
        { iterations = 20 },
        state2
      )
      
      -- Verify deterministic generation
      assert.equals(#values1, #values2)
      for i = 1, #values1 do
        assert.equals(values1[i][1], values2[i][1],
          string.format("Integer at iteration %d should match", i))
        assert.equals(values1[i][2], values2[i][2],
          string.format("String at iteration %d should match", i))
      end
    end)
  end)
  
  describe("Requirement 2.4: Return final RNG state", function()
    it("should return final RNG state after test execution", function()
      -- **Validates: Requirements 2.4**
      local initial_state = property.create_test_state(555)
      local initial_seed = initial_state.rng_seed
      
      local final_state = property.forall(
        { property.integer(1, 10) },
        function(n) end,
        { iterations = 50 },
        initial_state
      )
      
      -- Verify state is returned
      assert.is_not_nil(final_state)
      assert.is_table(final_state)
      
      -- Verify state has required fields
      assert.is_number(final_state.rng_seed)
      assert.is_number(final_state.iteration)
      
      -- Verify iteration count is correct
      assert.equals(50, final_state.iteration)
      
      -- Verify rng_seed is a valid seed value (in expected range)
      assert.is_true(final_state.rng_seed >= 1 and final_state.rng_seed < 2^31,
        "Final RNG seed should be in valid range")
    end)
  end)
  
  describe("Property 5: RNG State Determinism", function()
    it("should produce same generated values across runs with same state", function()
      -- **Validates: Requirements 2.2**
      -- Property 5: For any given RNG state and set of generators,
      -- calling property.forall() with that state should produce
      -- the same sequence of generated values across multiple runs.
      
      local test_seed = 12345
      
      -- First run: capture generated values
      local run1_values = {}
      local state1 = property.create_test_state(test_seed)
      property.forall(
        {
          property.integer(1, 1000),
          property.string(5, 15),
          property.boolean()
        },
        function(num, str, bool)
          table.insert(run1_values, {num = num, str = str, bool = bool})
        end,
        { iterations = 50 },
        state1
      )
      
      -- Second run: capture generated values with same seed
      local run2_values = {}
      local state2 = property.create_test_state(test_seed)
      property.forall(
        {
          property.integer(1, 1000),
          property.string(5, 15),
          property.boolean()
        },
        function(num, str, bool)
          table.insert(run2_values, {num = num, str = str, bool = bool})
        end,
        { iterations = 50 },
        state2
      )
      
      -- Third run: verify determinism holds across multiple runs
      local run3_values = {}
      local state3 = property.create_test_state(test_seed)
      property.forall(
        {
          property.integer(1, 1000),
          property.string(5, 15),
          property.boolean()
        },
        function(num, str, bool)
          table.insert(run3_values, {num = num, str = str, bool = bool})
        end,
        { iterations = 50 },
        state3
      )
      
      -- Verify all three runs produced identical sequences
      assert.equals(#run1_values, #run2_values)
      assert.equals(#run1_values, #run3_values)
      
      for i = 1, #run1_values do
        -- Verify integers match
        assert.equals(run1_values[i].num, run2_values[i].num,
          string.format("Run 1 and 2: Integer at iteration %d should match", i))
        assert.equals(run1_values[i].num, run3_values[i].num,
          string.format("Run 1 and 3: Integer at iteration %d should match", i))
        
        -- Verify strings match
        assert.equals(run1_values[i].str, run2_values[i].str,
          string.format("Run 1 and 2: String at iteration %d should match", i))
        assert.equals(run1_values[i].str, run3_values[i].str,
          string.format("Run 1 and 3: String at iteration %d should match", i))
        
        -- Verify booleans match
        assert.equals(run1_values[i].bool, run2_values[i].bool,
          string.format("Run 1 and 2: Boolean at iteration %d should match", i))
        assert.equals(run1_values[i].bool, run3_values[i].bool,
          string.format("Run 1 and 3: Boolean at iteration %d should match", i))
      end
    end)
    
    it("should produce different values with different seeds", function()
      -- **Validates: Requirements 2.2**
      -- Verify that different seeds produce different sequences
      -- (negative test to ensure determinism is based on seed)
      
      local seed1 = 11111
      local seed2 = 99999
      
      local values1 = {}
      local state1 = property.create_test_state(seed1)
      property.forall(
        { property.integer(1, 1000) },
        function(num)
          table.insert(values1, num)
        end,
        { iterations = 30 },
        state1
      )
      
      local values2 = {}
      local state2 = property.create_test_state(seed2)
      property.forall(
        { property.integer(1, 1000) },
        function(num)
          table.insert(values2, num)
        end,
        { iterations = 30 },
        state2
      )
      
      -- Verify sequences are different
      local all_same = true
      for i = 1, #values1 do
        if values1[i] ~= values2[i] then
          all_same = false
          break
        end
      end
      
      assert.is_false(all_same,
        "Different seeds should produce different value sequences")
    end)
    
    it("should maintain determinism across different generator types", function()
      -- **Validates: Requirements 2.2**
      -- Test determinism with various generator combinations
      
      local test_seed = 54321
      
      -- Run with multiple generator types
      local run1 = {}
      local state1 = property.create_test_state(test_seed)
      property.forall(
        {
          property.integer(1, 100),
          property.integer(100, 200),
          property.string(3, 8),
          property.boolean(),
          property.oneof({'a', 'b', 'c', 'd'})
        },
        function(int1, int2, str, bool, choice)
          table.insert(run1, {int1, int2, str, bool, choice})
        end,
        { iterations = 25 },
        state1
      )
      
      -- Repeat with same seed
      local run2 = {}
      local state2 = property.create_test_state(test_seed)
      property.forall(
        {
          property.integer(1, 100),
          property.integer(100, 200),
          property.string(3, 8),
          property.boolean(),
          property.oneof({'a', 'b', 'c', 'd'})
        },
        function(int1, int2, str, bool, choice)
          table.insert(run2, {int1, int2, str, bool, choice})
        end,
        { iterations = 25 },
        state2
      )
      
      -- Verify all values match
      assert.equals(#run1, #run2)
      for i = 1, #run1 do
        for j = 1, 5 do
          assert.equals(run1[i][j], run2[i][j],
            string.format("Value at iteration %d, generator %d should match", i, j))
        end
      end
    end)
  end)
  
  describe("Requirement 9.1: Create isolated generator state", function()
    it("should create isolated state when not provided", function()
      -- **Validates: Requirements 9.1**
      
      -- Run first test without state
      local state1 = property.forall(
        { property.integer(1, 10) },
        function(n) end,
        { iterations = 10 }
      )
      
      -- Wait a moment to ensure different timestamp
      local start_time = os.time()
      while os.time() == start_time do
        -- busy wait for 1 second
      end
      
      -- Run second test without state
      local state2 = property.forall(
        { property.integer(1, 10) },
        function(n) end,
        { iterations = 10 }
      )
      
      -- Verify each test got its own isolated state
      assert.is_not_nil(state1)
      assert.is_not_nil(state2)
      
      -- Both should have valid state structures
      assert.is_number(state1.rng_seed)
      assert.is_number(state2.rng_seed)
      assert.equals(10, state1.iteration)
      assert.equals(10, state2.iteration)
    end)
    
    it("should not share state between sequential tests", function()
      -- **Validates: Requirements 9.1, 9.2**
      
      -- Use explicit different seeds to ensure isolation
      local initial_seed1 = 111
      local state1 = property.create_test_state(initial_seed1)
      local values1 = {}
      local final_state1 = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(values1, n)
        end,
        { iterations = 5 },
        state1
      )
      
      local initial_seed2 = 222
      local state2 = property.create_test_state(initial_seed2)
      local values2 = {}
      local final_state2 = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(values2, n)
        end,
        { iterations = 5 },
        state2
      )
      
      -- Verify final states are returned
      assert.is_not_nil(final_state1)
      assert.is_not_nil(final_state2)
      
      -- Verify both states have valid structure
      assert.is_number(final_state1.rng_seed)
      assert.is_number(final_state2.rng_seed)
      
      -- Values should be different (different random sequences from different initial seeds)
      local all_same = true
      for i = 1, #values1 do
        if values1[i] ~= values2[i] then
          all_same = false
          break
        end
      end
      
      -- It's extremely unlikely all values match with different initial seeds
      assert.is_false(all_same, "Sequential tests with different seeds should produce different values")
    end)
  end)
  
  describe("Property 6: RNG State Isolation", function()
    it("should create independent state objects for each test", function()
      -- **Validates: Requirements 2.3, 9.1, 9.2**
      -- Property 6: For any sequence of property.forall() calls without explicit
      -- state sharing, each call should create isolated state that doesn't affect
      -- other tests.
      
      -- Run multiple tests without providing state (each should get isolated state)
      local states = {}
      
      for test_num = 1, 5 do
        local final_state = property.forall(
          { property.integer(1, 10) },
          function(n) end,
          { iterations = 10 }
          -- Note: No state parameter provided - should create isolated state
        )
        
        states[test_num] = final_state
      end
      
      -- Verify each test got its own state object
      for i = 1, #states do
        assert.is_not_nil(states[i],
          string.format("Test %d should have returned a state", i))
        assert.is_table(states[i],
          string.format("Test %d state should be a table", i))
        assert.is_number(states[i].rng_seed,
          string.format("Test %d should have an rng_seed", i))
        assert.equals(10, states[i].iteration,
          string.format("Test %d should have completed all iterations", i))
      end
      
      -- Verify states are independent objects (not shared references)
      for i = 1, #states - 1 do
        for j = i + 1, #states do
          -- States should be different table objects
          assert.is_not_equal(states[i], states[j],
            string.format("State %d and %d should be different objects", i, j))
        end
      end
    end)
    
    it("should not share RNG state between tests with explicit different seeds", function()
      -- **Validates: Requirements 2.3, 9.1, 9.2**
      -- Verify that tests with explicitly different seeds produce different sequences
      
      -- Use explicit different seeds to ensure we can detect isolation
      local seed1 = 11111
      local seed2 = 99999
      
      -- First test with seed1
      local values1 = {}
      local state1 = property.create_test_state(seed1)
      property.forall(
        { property.integer(1, 1000) },
        function(n)
          table.insert(values1, n)
        end,
        { iterations = 20 },
        state1
      )
      
      -- Second test with seed2
      local values2 = {}
      local state2 = property.create_test_state(seed2)
      property.forall(
        { property.integer(1, 1000) },
        function(n)
          table.insert(values2, n)
        end,
        { iterations = 20 },
        state2
      )
      
      -- Verify tests completed
      assert.equals(20, #values1)
      assert.equals(20, #values2)
      
      -- Verify sequences are different (proves isolation)
      local all_same = true
      for i = 1, #values1 do
        if values1[i] ~= values2[i] then
          all_same = false
          break
        end
      end
      
      assert.is_false(all_same,
        "Tests with different seeds should produce different sequences")
    end)
    
    it("should allow explicit state sharing when desired", function()
      -- **Validates: Requirements 2.3, 9.1, 9.2, 9.3**
      -- Verify that when we explicitly pass state between tests,
      -- the second test uses the updated seed from the first test
      
      -- Create an initial state
      local initial_seed = 42
      local state = property.create_test_state(initial_seed)
      
      -- First test: use state and get updated state
      local values1 = {}
      state = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(values1, n)
        end,
        { iterations = 5 },
        state
      )
      
      local seed_after_first_test = state.rng_seed
      
      -- Second test: use the updated state from first test
      local values2 = {}
      state = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(values2, n)
        end,
        { iterations = 5 },
        state
      )
      
      -- Now run two separate tests with fresh states
      local fresh_state1 = property.create_test_state(initial_seed)
      local fresh_values1 = {}
      fresh_state1 = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(fresh_values1, n)
        end,
        { iterations = 5 },
        fresh_state1
      )
      
      local fresh_state2 = property.create_test_state(initial_seed)
      local fresh_values2 = {}
      fresh_state2 = property.forall(
        { property.integer(1, 100) },
        function(n)
          table.insert(fresh_values2, n)
        end,
        { iterations = 5 },
        fresh_state2
      )
      
      -- Verify that sharing state means the second test gets the updated seed
      assert.is_not_equal(initial_seed, seed_after_first_test,
        "State should be updated after first test")
      
      -- Verify first test with shared state matches first fresh test
      assert.equals(5, #values1)
      assert.equals(5, #fresh_values1)
      for i = 1, 5 do
        assert.equals(fresh_values1[i], values1[i],
          string.format("First test values should match at position %d", i))
      end
      
      -- Verify second test with shared state is different from second fresh test
      -- (because it uses updated seed, not initial seed)
      local all_same = true
      for i = 1, 5 do
        if values2[i] ~= fresh_values2[i] then
          all_same = false
          break
        end
      end
      
      assert.is_false(all_same,
        "Second test with shared state should differ from fresh test (different seed)")
    end)
    
    it("should maintain isolation across different generator combinations", function()
      -- **Validates: Requirements 2.3, 9.1, 9.2**
      -- Test that isolation works with various generator types
      
      -- Use explicit seeds to ensure deterministic behavior
      local seeds = {12345, 23456, 34567, 45678, 56789}
      local test_configs = {
        { property.integer(1, 50) },
        { property.string(3, 8) },
        { property.boolean() },
        { property.integer(1, 100), property.string(5, 10) },
        { property.boolean(), property.integer(1, 20), property.oneof({'a', 'b', 'c'}) }
      }
      
      local test_results = {}
      
      for config_idx, generators in ipairs(test_configs) do
        local values = {}
        local state = property.create_test_state(seeds[config_idx])
        local final_state = property.forall(
          generators,
          function(...)
            local args = {...}
            table.insert(values, args)
          end,
          { iterations = 15 },
          state
        )
        
        test_results[config_idx] = {
          values = values,
          final_state = final_state,
          initial_seed = seeds[config_idx]
        }
      end
      
      -- Verify each test got isolated state
      for i = 1, #test_results do
        assert.is_not_nil(test_results[i].final_state)
        assert.is_number(test_results[i].final_state.rng_seed)
        assert.equals(15, test_results[i].final_state.iteration)
      end
      
      -- Verify states are independent (different objects)
      for i = 1, #test_results - 1 do
        for j = i + 1, #test_results do
          assert.is_not_equal(test_results[i].final_state, test_results[j].final_state,
            string.format("Test %d and %d should have different state objects", i, j))
        end
      end
    end)
  end)
end)

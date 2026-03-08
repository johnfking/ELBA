--
-- Property tests for test confluence
-- Feature: functional-refactoring
-- Task 6.5: Write property tests for test confluence
--

describe("Property Test Confluence", function()
  local property = require('spec.property')
  
  describe("Property 15: Property Test Confluence", function()
    it("should produce consistent results when tests run in different orders", function()
      -- **Validates: Requirements 9.4**
      -- Property 15: For any set of independent property tests, running them
      -- in different orders should produce consistent results for each individual test.
      
      -- Define three independent test functions that capture their results
      local test_results = {}
      
      local function test_a()
        local values = {}
        local state = property.create_test_state(12345)
        property.forall(
          { property.integer(1, 100) },
          function(n)
            table.insert(values, n)
          end,
          { iterations = 20 },
          state
        )
        return values
      end
      
      local function test_b()
        local values = {}
        local state = property.create_test_state(67890)
        property.forall(
          { property.string(5, 10) },
          function(s)
            table.insert(values, s)
          end,
          { iterations = 20 },
          state
        )
        return values
      end
      
      local function test_c()
        local values = {}
        local state = property.create_test_state(11111)
        property.forall(
          { property.boolean() },
          function(b)
            table.insert(values, b)
          end,
          { iterations = 20 },
          state
        )
        return values
      end
      
      -- Run tests in order: A, B, C
      local order1_a = test_a()
      local order1_b = test_b()
      local order1_c = test_c()
      
      -- Run tests in order: C, B, A
      local order2_c = test_c()
      local order2_b = test_b()
      local order2_a = test_a()
      
      -- Run tests in order: B, A, C
      local order3_b = test_b()
      local order3_a = test_a()
      local order3_c = test_c()
      
      -- Verify test A produced same results regardless of order
      assert.equals(#order1_a, #order2_a)
      assert.equals(#order1_a, #order3_a)
      for i = 1, #order1_a do
        assert.equals(order1_a[i], order2_a[i],
          string.format("Test A iteration %d should match between order 1 and 2", i))
        assert.equals(order1_a[i], order3_a[i],
          string.format("Test A iteration %d should match between order 1 and 3", i))
      end
      
      -- Verify test B produced same results regardless of order
      assert.equals(#order1_b, #order2_b)
      assert.equals(#order1_b, #order3_b)
      for i = 1, #order1_b do
        assert.equals(order1_b[i], order2_b[i],
          string.format("Test B iteration %d should match between order 1 and 2", i))
        assert.equals(order1_b[i], order3_b[i],
          string.format("Test B iteration %d should match between order 1 and 3", i))
      end
      
      -- Verify test C produced same results regardless of order
      assert.equals(#order1_c, #order2_c)
      assert.equals(#order1_c, #order3_c)
      for i = 1, #order1_c do
        assert.equals(order1_c[i], order2_c[i],
          string.format("Test C iteration %d should match between order 1 and 2", i))
        assert.equals(order1_c[i], order3_c[i],
          string.format("Test C iteration %d should match between order 1 and 3", i))
      end
    end)
    
    it("should maintain test independence across different execution orders", function()
      -- **Validates: Requirements 9.4**
      -- Verify that tests don't interfere with each other regardless of order
      
      -- Create test functions with different characteristics
      local function integer_test(seed)
        local sum = 0
        local state = property.create_test_state(seed)
        property.forall(
          { property.integer(1, 50) },
          function(n)
            sum = sum + n
          end,
          { iterations = 30 },
          state
        )
        return sum
      end
      
      local function string_test(seed)
        local total_length = 0
        local state = property.create_test_state(seed)
        property.forall(
          { property.string(3, 8) },
          function(s)
            total_length = total_length + #s
          end,
          { iterations = 30 },
          state
        )
        return total_length
      end
      
      local function boolean_test(seed)
        local true_count = 0
        local state = property.create_test_state(seed)
        property.forall(
          { property.boolean() },
          function(b)
            if b then true_count = true_count + 1 end
          end,
          { iterations = 30 },
          state
        )
        return true_count
      end
      
      -- Use fixed seeds for determinism
      local seed1, seed2, seed3 = 11111, 22222, 33333
      
      -- Run in order 1: integer, string, boolean
      local order1_int = integer_test(seed1)
      local order1_str = string_test(seed2)
      local order1_bool = boolean_test(seed3)
      
      -- Run in order 2: boolean, integer, string
      local order2_bool = boolean_test(seed3)
      local order2_int = integer_test(seed1)
      local order2_str = string_test(seed2)
      
      -- Run in order 3: string, boolean, integer
      local order3_str = string_test(seed2)
      local order3_bool = boolean_test(seed3)
      local order3_int = integer_test(seed1)
      
      -- Verify each test produced consistent results across orders
      assert.equals(order1_int, order2_int,
        "Integer test should produce same result in order 1 and 2")
      assert.equals(order1_int, order3_int,
        "Integer test should produce same result in order 1 and 3")
      
      assert.equals(order1_str, order2_str,
        "String test should produce same result in order 1 and 2")
      assert.equals(order1_str, order3_str,
        "String test should produce same result in order 1 and 3")
      
      assert.equals(order1_bool, order2_bool,
        "Boolean test should produce same result in order 1 and 2")
      assert.equals(order1_bool, order3_bool,
        "Boolean test should produce same result in order 1 and 3")
    end)
    
    it("should handle interleaved test execution without state pollution", function()
      -- **Validates: Requirements 9.4**
      -- Test that partially executing tests and then switching doesn't affect results
      
      -- Create generators that we'll use in multiple tests
      local int_gen = property.integer(1, 100)
      local str_gen = property.string(5, 10)
      
      -- Test 1: Run completely
      local test1_values = {}
      local state1 = property.create_test_state(55555)
      property.forall(
        { int_gen },
        function(n)
          table.insert(test1_values, n)
        end,
        { iterations = 15 },
        state1
      )
      
      -- Test 2: Run completely
      local test2_values = {}
      local state2 = property.create_test_state(66666)
      property.forall(
        { str_gen },
        function(s)
          table.insert(test2_values, s)
        end,
        { iterations = 15 },
        state2
      )
      
      -- Now run them again in reverse order
      local test2_values_again = {}
      local state2_again = property.create_test_state(66666)
      property.forall(
        { str_gen },
        function(s)
          table.insert(test2_values_again, s)
        end,
        { iterations = 15 },
        state2_again
      )
      
      local test1_values_again = {}
      local state1_again = property.create_test_state(55555)
      property.forall(
        { int_gen },
        function(n)
          table.insert(test1_values_again, n)
        end,
        { iterations = 15 },
        state1_again
      )
      
      -- Verify test 1 produced same results
      assert.equals(#test1_values, #test1_values_again)
      for i = 1, #test1_values do
        assert.equals(test1_values[i], test1_values_again[i],
          string.format("Test 1 iteration %d should match", i))
      end
      
      -- Verify test 2 produced same results
      assert.equals(#test2_values, #test2_values_again)
      for i = 1, #test2_values do
        assert.equals(test2_values[i], test2_values_again[i],
          string.format("Test 2 iteration %d should match", i))
      end
    end)
    
    it("should maintain confluence with multiple generator types", function()
      -- **Validates: Requirements 9.4**
      -- Test confluence with complex generator combinations
      
      local function complex_test_1(seed)
        local results = {}
        local state = property.create_test_state(seed)
        property.forall(
          {
            property.integer(1, 50),
            property.string(3, 7),
            property.boolean()
          },
          function(n, s, b)
            table.insert(results, {num = n, str = s, bool = b})
          end,
          { iterations = 25 },
          state
        )
        return results
      end
      
      local function complex_test_2(seed)
        local results = {}
        local state = property.create_test_state(seed)
        property.forall(
          {
            property.oneof({'a', 'b', 'c', 'd'}),
            property.integer(100, 200)
          },
          function(choice, n)
            table.insert(results, {choice = choice, num = n})
          end,
          { iterations = 25 },
          state
        )
        return results
      end
      
      -- Run in order: test1, test2
      local order1_test1 = complex_test_1(77777)
      local order1_test2 = complex_test_2(88888)
      
      -- Run in order: test2, test1
      local order2_test2 = complex_test_2(88888)
      local order2_test1 = complex_test_1(77777)
      
      -- Verify test 1 results match
      assert.equals(#order1_test1, #order2_test1)
      for i = 1, #order1_test1 do
        assert.equals(order1_test1[i].num, order2_test1[i].num,
          string.format("Test 1 iteration %d: num should match", i))
        assert.equals(order1_test1[i].str, order2_test1[i].str,
          string.format("Test 1 iteration %d: str should match", i))
        assert.equals(order1_test1[i].bool, order2_test1[i].bool,
          string.format("Test 1 iteration %d: bool should match", i))
      end
      
      -- Verify test 2 results match
      assert.equals(#order1_test2, #order2_test2)
      for i = 1, #order1_test2 do
        assert.equals(order1_test2[i].choice, order2_test2[i].choice,
          string.format("Test 2 iteration %d: choice should match", i))
        assert.equals(order1_test2[i].num, order2_test2[i].num,
          string.format("Test 2 iteration %d: num should match", i))
      end
    end)
    
    it("should verify confluence across many test permutations", function()
      -- **Validates: Requirements 9.4**
      -- Test with more tests and more orderings
      
      -- Define 5 simple tests
      local tests = {
        function(seed)
          local sum = 0
          local state = property.create_test_state(seed)
          property.forall(
            { property.integer(1, 10) },
            function(n) sum = sum + n end,
            { iterations = 10 },
            state
          )
          return sum
        end,
        function(seed)
          local count = 0
          local state = property.create_test_state(seed)
          property.forall(
            { property.boolean() },
            function(b) if b then count = count + 1 end end,
            { iterations = 10 },
            state
          )
          return count
        end,
        function(seed)
          local total_len = 0
          local state = property.create_test_state(seed)
          property.forall(
            { property.string(1, 5) },
            function(s) total_len = total_len + #s end,
            { iterations = 10 },
            state
          )
          return total_len
        end,
        function(seed)
          local product = 1
          local state = property.create_test_state(seed)
          property.forall(
            { property.integer(1, 3) },
            function(n) product = product * n end,
            { iterations = 10 },
            state
          )
          return product
        end,
        function(seed)
          local max_val = 0
          local state = property.create_test_state(seed)
          property.forall(
            { property.integer(1, 100) },
            function(n) if n > max_val then max_val = n end end,
            { iterations = 10 },
            state
          )
          return max_val
        end
      }
      
      -- Use fixed seeds for each test
      local seeds = {10001, 20002, 30003, 40004, 50005}
      
      -- Run in original order
      local order1_results = {}
      for i = 1, #tests do
        order1_results[i] = tests[i](seeds[i])
      end
      
      -- Run in reverse order
      local order2_results = {}
      for i = #tests, 1, -1 do
        order2_results[i] = tests[i](seeds[i])
      end
      
      -- Run in shuffled order (2, 4, 1, 5, 3)
      local order3_results = {}
      local shuffle = {2, 4, 1, 5, 3}
      for _, idx in ipairs(shuffle) do
        order3_results[idx] = tests[idx](seeds[idx])
      end
      
      -- Verify all tests produced consistent results
      for i = 1, #tests do
        assert.equals(order1_results[i], order2_results[i],
          string.format("Test %d should match between order 1 and 2", i))
        assert.equals(order1_results[i], order3_results[i],
          string.format("Test %d should match between order 1 and 3", i))
      end
    end)
  end)
end)

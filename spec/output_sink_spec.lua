describe('OutputSink Module - Task 7.1 Verification', function()
  local output_sink = require('spec.output_sink')
  
  describe('create_buffer_sink', function()
    it('creates an OutputSink with write and get_output methods', function()
      local sink = output_sink.create_buffer_sink()
      
      assert.is_not_nil(sink)
      assert.is_function(sink.write)
      assert.is_function(sink.get_output)
    end)
    
    it('captures text written to the sink', function()
      local sink = output_sink.create_buffer_sink()
      
      sink:write('Hello')
      sink:write(' ')
      sink:write('World')
      
      local output = sink:get_output()
      assert.equals('Hello World', output)
    end)
    
    it('returns empty string when no text has been written', function()
      local sink = output_sink.create_buffer_sink()
      
      local output = sink:get_output()
      assert.equals('', output)
    end)
    
    it('accumulates multiple writes', function()
      local sink = output_sink.create_buffer_sink()
      
      for i = 1, 5 do
        sink:write(tostring(i))
      end
      
      local output = sink:get_output()
      assert.equals('12345', output)
    end)
    
    it('handles empty string writes', function()
      local sink = output_sink.create_buffer_sink()
      
      sink:write('')
      sink:write('test')
      sink:write('')
      
      local output = sink:get_output()
      assert.equals('test', output)
    end)
    
    it('creates independent sinks that do not share state', function()
      local sink1 = output_sink.create_buffer_sink()
      local sink2 = output_sink.create_buffer_sink()
      
      sink1:write('sink1')
      sink2:write('sink2')
      
      assert.equals('sink1', sink1:get_output())
      assert.equals('sink2', sink2:get_output())
    end)
  end)
end)

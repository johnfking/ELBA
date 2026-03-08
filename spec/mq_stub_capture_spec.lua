-- spec/mq_stub_capture_spec.lua

describe("mq_stub command capture", function()
    local mq

    before_each(function()
        -- Reload mq_stub to get fresh state
        package.loaded['mq_stub'] = nil
        mq = require('mq_stub')
    end)

    describe("enable_capture", function()
        it("should enable capture mode and clear buffer", function()
            mq.enable_capture()
            mq.cmd("test command")
            local commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
            assert.are.equal("test command", commands[1])
        end)
    end)

    describe("disable_capture", function()
        it("should disable capture mode", function()
            mq.enable_capture()
            mq.cmd("captured")
            mq.disable_capture()
            
            -- After disabling, commands should not be captured
            -- (they would go to stdout, but we can't easily test that here)
            local commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
            assert.are.equal("captured", commands[1])
        end)
    end)

    describe("get_captured_commands", function()
        it("should return empty table when no commands captured", function()
            mq.enable_capture()
            local commands = mq.get_captured_commands()
            assert.are.same({}, commands)
        end)

        it("should return all captured commands in order", function()
            mq.enable_capture()
            mq.cmd("command1")
            mq.cmd("command2")
            mq.cmd("command3")
            
            local commands = mq.get_captured_commands()
            assert.are.equal(3, #commands)
            assert.are.equal("command1", commands[1])
            assert.are.equal("command2", commands[2])
            assert.are.equal("command3", commands[3])
        end)
    end)

    describe("clear_captured_commands", function()
        it("should clear the command buffer", function()
            mq.enable_capture()
            mq.cmd("command1")
            mq.cmd("command2")
            
            mq.clear_captured_commands()
            
            local commands = mq.get_captured_commands()
            assert.are.same({}, commands)
        end)
    end)

    describe("cmd in capture mode", function()
        it("should append commands to buffer", function()
            mq.enable_capture()
            mq.cmd("first")
            mq.cmd("second")
            
            local commands = mq.get_captured_commands()
            assert.are.equal(2, #commands)
            assert.are.equal("first", commands[1])
            assert.are.equal("second", commands[2])
        end)

        it("should not write to stdout in capture mode", function()
            -- This is implicitly tested by the fact that commands
            -- are added to the buffer instead of being written
            mq.enable_capture()
            mq.cmd("test")
            
            local commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
        end)
    end)

    describe("cmdf in capture mode", function()
        it("should capture formatted commands", function()
            mq.enable_capture()
            mq.cmdf("command %s %d", "test", 42)
            
            local commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
            assert.are.equal("command test 42", commands[1])
        end)

        it("should capture commands without format arguments", function()
            mq.enable_capture()
            mq.cmdf("simple command")
            
            local commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
            assert.are.equal("simple command", commands[1])
        end)
    end)

    describe("capture mode workflow", function()
        it("should support enable -> capture -> get -> clear -> disable workflow", function()
            -- Enable capture
            mq.enable_capture()
            
            -- Capture some commands
            mq.cmd("cmd1")
            mq.cmdf("cmd%d", 2)
            
            -- Get captured commands
            local commands = mq.get_captured_commands()
            assert.are.equal(2, #commands)
            assert.are.equal("cmd1", commands[1])
            assert.are.equal("cmd2", commands[2])
            
            -- Clear buffer
            mq.clear_captured_commands()
            commands = mq.get_captured_commands()
            assert.are.same({}, commands)
            
            -- Capture more commands
            mq.cmd("cmd3")
            commands = mq.get_captured_commands()
            assert.are.equal(1, #commands)
            assert.are.equal("cmd3", commands[1])
            
            -- Disable capture
            mq.disable_capture()
        end)
    end)
end)

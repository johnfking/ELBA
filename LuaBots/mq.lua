local use_stub = os.getenv('LUABOTS_STUB_MQ') == '1'

if not use_stub then
    local ok, real = pcall(require, 'mq')
    if ok then
        return real
    end
end

return require('LuaBots.mq_stub')

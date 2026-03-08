--
-- HTTP Client Interface and Implementations
--
-- Provides abstraction for HTTP requests to enable dependency injection
-- and testing without actual network calls.
--

---@class HTTPClient
---@field request fun(opts: table): string, number
-- Interface for HTTP client implementations
-- opts: { url = string }
-- returns: body (string), code (number)

local HTTPClient = {}

--- Create a default HTTP client using luasocket
--- This implementation makes real HTTP requests using the luasocket library
---@return HTTPClient HTTP client instance
function HTTPClient.create_default_http_client()
  local http = require('socket.http')
  local ltn12 = require('ltn12')
  
  return {
    request = function(opts)
      local response = {}
      local _, code = http.request{
        url = opts.url,
        sink = ltn12.sink.table(response)
      }
      return table.concat(response), code
    end
  }
end

--- Create a mock HTTP client for testing
--- This implementation returns predefined responses without making network calls
---@param responses table<string, {body: string, code: number}> Map of URLs to responses
---@return HTTPClient HTTP client instance
function HTTPClient.create_mock_http_client(responses)
  return {
    request = function(opts)
      local response = responses[opts.url] or { body = '{"names":["TestBot"]}', code = 200 }
      return response.body, response.code
    end
  }
end

return HTTPClient

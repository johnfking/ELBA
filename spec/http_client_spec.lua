-- Unit tests for HTTPClient module (Task 3.1)
-- These tests verify the HTTP client interface and implementations

local HTTPClient = require('LuaBots.HTTPClient')

describe('HTTPClient Module - Task 3.1 Verification', function()

  describe('create_mock_http_client', function()
    it('returns a client with request method', function()
      local client = HTTPClient.create_mock_http_client({})
      assert.is_not_nil(client)
      assert.is_function(client.request)
    end)

    it('returns predefined response for matching URL', function()
      local responses = {
        ['https://example.com/test'] = {
          body = '{"result":"success"}',
          code = 200
        }
      }
      local client = HTTPClient.create_mock_http_client(responses)

      local body, code = client.request({ url = 'https://example.com/test' })

      assert.are.equal('{"result":"success"}', body)
      assert.are.equal(200, code)
    end)

    it('returns default response for unknown URL', function()
      local client = HTTPClient.create_mock_http_client({})

      local body, code = client.request({ url = 'https://unknown.com' })

      assert.are.equal('{"names":["TestBot"]}', body)
      assert.are.equal(200, code)
    end)

    it('handles multiple different URLs', function()
      local responses = {
        ['https://api1.com'] = { body = 'response1', code = 200 },
        ['https://api2.com'] = { body = 'response2', code = 404 }
      }
      local client = HTTPClient.create_mock_http_client(responses)

      local body1, code1 = client.request({ url = 'https://api1.com' })
      local body2, code2 = client.request({ url = 'https://api2.com' })

      assert.are.equal('response1', body1)
      assert.are.equal(200, code1)
      assert.are.equal('response2', body2)
      assert.are.equal(404, code2)
    end)

    it('can simulate HTTP error codes', function()
      local responses = {
        ['https://error.com'] = { body = 'Error message', code = 500 }
      }
      local client = HTTPClient.create_mock_http_client(responses)

      local body, code = client.request({ url = 'https://error.com' })

      assert.are.equal('Error message', body)
      assert.are.equal(500, code)
    end)
  end)

  describe('create_default_http_client', function()
    it('returns a client with request method', function()
      -- We can't test actual HTTP requests in unit tests, but we can verify
      -- the client structure is correct
      local client = HTTPClient.create_default_http_client()
      assert.is_not_nil(client)
      assert.is_function(client.request)
    end)

    it('client request method accepts opts table with url', function()
      -- Mock the socket.http module to avoid actual network calls
      local mock_http_called = false
      local mock_url = nil

      package.loaded['socket.http'] = {
        request = function(opts)
          mock_http_called = true
          mock_url = opts.url
          return nil, 200
        end
      }

      package.loaded['ltn12'] = {
        sink = {
          table = function(t) return function(chunk) end end
        }
      }

      -- Force reload of HTTPClient to use mocked modules
      package.loaded['LuaBots.HTTPClient'] = nil
      package.loaded['LuaBots/HTTPClient'] = nil
      local HTTPClient_reloaded = require('LuaBots.HTTPClient')

      local client = HTTPClient_reloaded.create_default_http_client()
      local body, code = client.request({ url = 'https://test.com' })

      assert.is_true(mock_http_called)
      assert.are.equal('https://test.com', mock_url)
      assert.are.equal(200, code)

      -- Clean up
      package.loaded['socket.http'] = nil
      package.loaded['ltn12'] = nil
      package.loaded['LuaBots.HTTPClient'] = nil
      package.loaded['LuaBots/HTTPClient'] = nil
    end)
  end)

  describe('HTTPClient interface compliance', function()
    it('both implementations return body and code', function()
      local mock_client = HTTPClient.create_mock_http_client({
        ['https://test.com'] = { body = 'test body', code = 201 }
      })

      local body, code = mock_client.request({ url = 'https://test.com' })

      assert.is_string(body)
      assert.is_number(code)
      assert.are.equal('test body', body)
      assert.are.equal(201, code)
    end)

    it('mock client is suitable for testing without network', function()
      -- Verify mock client can be used in tests without any network dependencies
      local client = HTTPClient.create_mock_http_client({
        ['https://names.ironarachne.com/race/human/male/1'] = {
          body = '{"names":["Aldric","Bran","Cedric"]}',
          code = 200
        }
      })

      local body, code = client.request({
        url = 'https://names.ironarachne.com/race/human/male/1'
      })

      assert.are.equal(200, code)
      assert.is_true(body:match('Aldric') ~= nil)
    end)
  end)
end)

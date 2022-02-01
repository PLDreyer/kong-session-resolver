local http = require('resty.http')
local cjson = require("cjson")
local errlog = require("ngx.errlog")

local M = {}
local ngx_DEBUG = ngx.DEBUG

-- parse header array to header table
local function parse_headers(headers_to_append)
  local header_table = {}
  M.debug_log_table("Generate header table from array for session request: ", headers_to_append)
  for _, header in pairs(headers_to_append) do
    for k, v in string.gmatch(header, "([^:]+):(.+)") do
      if not k == nil and not v == nil then
        header_table[k] = v
      end
    end
  end
  M.debug_log_table("Generated header table for session request: ", header_table)
  return header_table
end

-- parse plugin config
function M.get_options(plugin_conf)
 local options = {
    request_method = plugin_conf.request_method,
    header_to_resolve = plugin_conf.header_to_resolve,
    introspection_timeout_ms = plugin_conf.introspection_endpoint_ms,
    introspection_endpoint = plugin_conf.introspection_endpoint,
    request_headers_to_append = parse_headers(plugin_conf.request_headers_to_append),
    upstream_session_header = plugin_conf.upstream_session_header,
    response_body_property_to_use = plugin_conf.response_body_property_to_use,
  }
  M.debug_log_table("Plugin Config for session resolver: ", options)
  return options
end

-- make http request to introspection endpoint
function M.make_request(header_value, request_method, introspection_endpoint, request_headers, introspection_timeout_ms)
  local httpc = http.new()
  httpc:set_timeout(introspection_timeout_ms)
  kong.log.debug("Timeout for session request: "..introspection_timeout_ms)

  local request_uri = introspection_endpoint.."/"..header_value
  kong.log.debug("Introspection endpoint for session request: "..request_uri)

  local res, err = httpc:request_uri(request_uri, {
    method = request_method,
    headers = request_headers,
  })
  M.debug_log_table("Response session request: ", res)
  M.debug_log_table("Error session request: ", err)

  return res, err
end

-- receive property from response and inject in header
function M.inject_header(res, upstream_session_header, response_body_property_to_use)
  if res == nil then
    kong.log.warn("Response from session request is nil")
    local value = ngx.encode_base64("nil")
    kong.log.warn("Set upstream session header to nil")
    kong.service.request.set_header(upstream_session_header, value)
    return
  end

  local response_value = cjson.decode(res.body)
  M.debug_log_table("Response body: ", response_value)
  for k in string.gmatch(response_body_property_to_use, "[^%.]+") do
    if response_value[k] == nil then
      kong.log.warn("Property '"..k.."' do not exist on response")
      kong.log.warn("Set upstream session header to nil")
      response_value = nil
      break
    end
    response_value = response_value[k]
  end

  local value = ngx.encode_base64(cjson.encode(response_value))
  kong.log.debug("Base64 encoded value for upstream session header: ", value)
  kong.service.request.set_header(upstream_session_header, value)
end

function M.debug_log_table(...)
  local log_level = errlog.get_sys_filter_level()
  if log_level == ngx_DEBUG then
    kong.log.inspect(...)
  end
end

return M

local utils = require("kong.plugins.session-resolver.utils")

local M = {}

function M.resolve_session(resolver_config, header_value)
  local res, err

  kong.log.debug("Resolve session for ID: "..header_value)
  res, err = utils.make_request(header_value,
    resolver_config.request_method,
    resolver_config.introspection_endpoint,
    resolver_config.request_headers_to_append,
    resolver_config.introspection_timeout_ms)


  if err then
    kong.log.warn("Could not resolve session: "..err)
  end

  utils.inject_header(res, resolver_config.upstream_session_header, resolver_config.response_body_property_to_use)
end

return M;

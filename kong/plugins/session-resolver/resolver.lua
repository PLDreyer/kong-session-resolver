local utils = require("kong.plugins.session-resolver.utils")

local M = {}

function M.resolve_session(resolver_config, x_consumer_custom_id)
  local res, err

  if x_consumer_custom_id == nil then
    kong.log.warn("No 'X-Consumer-Custom-ID' for session resolver found")
  else
    kong.log.debug("Resolve session for ID: "..x_consumer_custom_id)
    res, err = utils.make_request(x_consumer_custom_id, resolver_config.method, resolver_config.introspection_endpoint, resolver_config.headers, resolver_config.timeout)
  end

  if err then
    kong.log.warn("Could not resolve session: "..err)
  end

  utils.inject_header(res, resolver_config.upstream_session_header, resolver_config.response_body_property_to_use)
end

return M;

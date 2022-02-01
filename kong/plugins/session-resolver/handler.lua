local utils = require("kong.plugins.session-resolver.utils")
local resolver = require("kong.plugins.session-resolver.resolver")

local plugin = {
  -- priority lower then all authentication plugins
  PRIORITY = 970,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)
  local x_consumer_custom_id = kong.request.get_header("X-Consumer-Custom-ID")

  if x_consumer_custom_id == nil then
    kong.log.warn("No 'X-Consumer-Custom-ID' for session resolver found")
    return
  end

  local resolver_config = utils.get_options(plugin_conf)
  resolver.resolve_session(resolver_config, x_consumer_custom_id)
end

return plugin

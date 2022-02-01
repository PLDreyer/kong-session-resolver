local utils = require("kong.plugins.session-resolver.utils")
local resolver = require("kong.plugins.session-resolver.resolver")

local plugin = {
  -- priority lower then all authentication plugins
  PRIORITY = 970,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)
  local resolver_config = utils.get_options(plugin_conf)

  local header_value = kong.request.get_header(resolver_config.header_to_resolve)
  if header_value == nil then
    kong.log.warn("No 'X-Consumer-Custom-ID' for session resolver found")
    return
  end

  resolver.resolve_session(resolver_config, header_value)
end

return plugin

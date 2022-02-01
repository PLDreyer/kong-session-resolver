local typedefs = require "kong.db.schema.typedefs"

local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

function validate_headers(pair)
  local name, value = pair:match("^([^:]+):*(.-)$")
  if name == nil and value == nil then
    return nil, "Header format is not valid"
  end

  return true
end

local schema = {
  name = plugin_name,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          {
            request_method = {
              type = "string",
              default = "GET",
              required = true
            }
          },
          {
            introspection_endpoint = {
              type = "string",
              required = true,
            },
          },
          {
            request_headers_to_append = {
              type = "array",
              default = {},
              required = true,
              elements = { type = "string", match = "^([^:]+):*(.-)$", custom_validator = validate_headers }
            }
          },
          {
            upstream_session_header = {
              type = "string",
              required = true
            },
          },
          {
            response_body_property_to_use = {
              type = "string",
              required = true
            }
          }
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema

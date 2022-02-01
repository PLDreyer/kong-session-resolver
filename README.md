Kong Session Resolver
====================

Used to get user information about a resolved customer-id

Features
=================================
  - dynamic request method
  - choose header value to resolve session with
  - dynamic introspection endpoint
  - optionally append headers to request
  - choose upstream header for session
  - choose deeply nested response properties for upstream
  - upstream resolved value Base64(JSON-String) or Base64("nil")

Dependencies
============
- lua-resty-http >= 0.08

Configuration
-------
```lua
local config = {
    -- GET / POST / PUT / PATCH / DELETE / OPTIONS
    request_method = "GET", -- DEFAULT

    -- header with value to resolve session with
    header_to_resolve = "X-Consumer-Custom-ID", -- DEFAULT

    -- timeout for introspection request in ms
    introspection_timeout_ms = 2000, -- DEFAULT

    -- introspection endpoint -> introspection_endpoint + "/" + x-consumer-custom-id
    introspection_endpoint = "https://example.introspection.page/with/path",

    request_headers_to_append = {
        "X-Example-One:Value1",
        "X-Example-Two:Value2"
    },

    -- place resolved session in chosen upstream header
    upstream_session_header = "X-Session-Header",

    -- choose nested response property as upstream value
    --[[
    {
        nested: {
            deeplyNested: {
                ...
            }
        }
    }
    --]]
    response_body_property_to_use = "nested.deeplyNested"
}
```

Implementation
===============
- Docker Base Kong:v2.6
- Kong Config or Env
    - extend lua package path
    - update plugins to integrate

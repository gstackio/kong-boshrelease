local _M = {}

function _M.execute(conf)
  --[[
    1. convert space guid to org guid
    cf m from cli
    GET /v2/spaces/:guid/services
    GET /v2/spaces/:guid to get organization_guid

    2. get all services from Nurego
    GET /v1/catalog on Nurego endpoint to get all services from Nurego

    3. iterate through services using service guid

    4. return newly packaged services to the CF CLI

  ]]--

j
  --[[
    1. convert space guid to org guid
    cf m from cli
    incoming request: 
      GET /v2/spaces/:guid/services

    create a request to:
      GET /v2/spaces/:guid
    to get organization_guid
    ]]--
  local http = require("socket.http")
  local rawHeader = ngx.req.raw_header()

  --regext to check if the request is sent to the uri that we're listening for (with a guid in the middle there)
  local uri_location_matches, err = ngx.re.match(ngx.req.uri, "/v2/spaces/[0-9a-fA-F]{8}\-([0-9a-fA-F]{4}\-){3}[0-9a-fA-F]{12}/services")
  if not uri_location_matches
    if err then
      ngx.log(ngx.ERR, "error: ", err)
      return
    end
    ngx.print("match not found")
  end

  -- if the request is of the type we're looking for (a GET request to /v2/spaces/:guid/services),
  -- then we can ping the spaces endpoint to get the guid we care about (org guid in this case)
  if (ngx.req.get_method() == "GET") and uri_location_matches then
    space_guid = string.match(ngx.req.ui, "*/v2/spaces/(*)/services")
    result, statuscode, content = http.request("https://api.system.aws-usw02-sb.ice.predix.io/v2/spaces/" .. space_guid)
    -- local org_guid = content.organization_guid
    ngx.print("result:  " .. result)
    ngx.print("statuscode:  " .. statuscode)
    ngx.print("content:  " .. content)
  end

  ngx.print(ngx.req.raw_header())

-- 2. get all services from Nurego
-- GET /v1/catalog on Nurego endpoint to get services



end

return _M

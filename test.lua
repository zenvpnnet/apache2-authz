local json = require "json"
local request = require "http.request"

local req_timeout = 10
local req = request.new_from_uri("https://app.zenvpn.net/api/v1/get_ips/?domain_name=wp1.teamfm.com&access_token=ccd753e5-a771-4124-a19d-4ae534148d97")

local headers, stream = req:go(req_timeout)
if headers == nil then
	io.stderr:write(tostring(stream), "\n")
	os.exit(1)
end
print("## HEADERS")
for k, v in headers:each() do
	print(k, v)
end
print()
print("## BODY")
local body, err = stream:get_body_as_string()
if not body and err then
	io.stderr:write(tostring(err), "\n")
	os.exit(1)
end
print(body)

local map = {}

for i, ip in ipairs(json.decode(body).ipAddresses) do
    map[ip] = true
end

print(map["5.2.64.126"])
print(map["127.0.0.1"])

for k, v in pairs(map) do
    print(k, v)
end

local json = require "json"
local http = require "socket.http"

local domain = "wp1.teamfm.com"
local token = "ccd753e5-a771-4124-a19d-4ae534148d97"
local body, status = http.request("https://app.zenvpn.net/api/v1/get_ips/?domain_name=" .. domain .. "&access_token=" .. token)

print(status)

local map = {}

for _, ip in ipairs(json.decode(body).ipAddresses) do
    map[ip] = true
end

for k, v in pairs(map) do
    print(k, v)
end

require "apache2"
local json = require "json"
local http = require "socket.http"
local url = require "socket.url"

--- @type table<string, table<string, boolean>>
CACHE = {}

local CACHE_MS = 60000000

--- @param domain string
--- @param token string
--- @return table<string, boolean>
--- @return boolean
local function fetch_ips(domain, token)
    local map = {}

    local body, status = http.request("https://app.zenvpn.net/api/v1/get_ips/?domain_name=" .. url.escape(domain) .. "&access_token=" .. url.escape(token))
    if status == 403 or status == 404 then
        return map, true
    end
    if status ~= 200 then
        return map, false
    end

    for _, ip in ipairs(json.decode(body).ipAddresses) do
        map[ip] = true
    end

    return map, true
end

--- @param now integer
--- @param fn function
--- @param ... any
local function cache(now, fn, ...)
    local key = table.concat({...}, "@")
    if CACHE[key] ~= nil and now - CACHE[key].__cached < CACHE_MS then
        return CACHE[key], true
    end

    local data, ok = fn(...)

    if ok then
        data.__cached = now
        CACHE[key] = data
    end

    return data, ok
end

--- @param times integer
--- @param fn function
local function retry(times, fn)
    return function (...)
        local data, ok = fn(...)
        while not ok and times > 0 do
            data, ok = fn(...)
            times = times - 1
        end

        return data, ok
    end
end

--- @param r apache2.request_rec
--- @param token string
function CheckIPs(r, token)
    local domain = r.hostname
    local ips, _ = cache(r:clock(), retry(3, fetch_ips), domain, token)

    if ips[r.useragent_ip] then
        return apache2.AUTHZ_GRANTED

    else
        return apache2.AUTHZ_DENIED
    end
end

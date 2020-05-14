local apiKey = "API KEY GOES HERE"
local url = "https://signals.api.auth0.com/v2.0/ip/"

local kickMessage = "You have been kicked from this server because you joined with a blacklisted IP."

local showConnectCountries = true
local banTime = 60 * 24 -- in minutes

hook.Add("CheckPassword", "VPNBlocker.CheckIP", function (sid64, ip)
    local s = string.find(ip, ":")
    ip = string.sub(ip, 1, s-1)
    print("Checking IP " .. ip .. "..")
    http.Fetch(url .. ip, function (body, size, headers, code)
        if (code == 200) then
            local tbl = util.JSONToTable(body)
            local score = tbl.fullip.score
            local country = tbl.fullip.geo.as.country
            
            if (showConnectCountries) then
                print(sid64 .. " connecting from country " .. country)
            end

            if (score != 0) then
                local sid = util.SteamIDFrom64(sid64)

                if (ULX) then
                    ULib.addBan(sid, banTime, kickMessage, sid)
                end
                if (sam) then
                    sam.player.ban_id(sid, banTime, kickMessage)
                end

            end

        else
            ErrorNoHalt("Tried to check " .. ply:Name() .. "'s IP, but API returned code " .. code .. "!")
        end
    end, nil, {
        ["X-Auth-Token"] = apiKey
    })
end)
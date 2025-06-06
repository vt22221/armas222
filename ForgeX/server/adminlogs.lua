-- ForgeX Admin Logs (Server-side)

local adminLogs = {} -- { {time=timestamp, type="giftcode", user="nick", details="..."} }

function fx_adminLog(plr, typ, details)
    table.insert(adminLogs, 1, {time=os.time(), type=typ, user=getPlayerName(plr), details=details})
    if #adminLogs > 1000 then table.remove(adminLogs) end
end

addEvent("forgex:requestAdminLogs", true)
addEventHandler("forgex:requestAdminLogs", root, function(filterType)
    if getElementData(client, "admin") ~= true then return end
    local logs = {}
    for _,log in ipairs(adminLogs) do
        if filterType=="all" or tostring(log.type)==filterType then
            table.insert(logs, log)
        end
        if #logs >= 20 then break end
    end
    triggerClientEvent(client, "forgex:syncAdminLogs", client, logs)
end)
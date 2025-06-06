-- ForgeX Admin Logs Panel (Client-side)

local isAdminLogsVisible = false
local adminLogsData = {}

addEvent("forgex:syncAdminLogs", true)
addEventHandler("forgex:syncAdminLogs", root, function(logs)
    adminLogsData = logs or {}
end)

bindKey("F10", "down", function()
    isAdminLogsVisible = not isAdminLogsVisible
    if isAdminLogsVisible then
        triggerServerEvent("forgex:requestAdminLogs", localPlayer, "all")
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isAdminLogsVisible and btn == "escape" and press then
        isAdminLogsVisible = false
        cancelEvent()
    end
end)

function drawAdminLogsPanel()
    if not isAdminLogsVisible then return end
    local x, y, w, h = 120, 100, 720, 400
    dxDrawRectangle(x, y, w, h, tocolor(30,10,10,230))
    dxDrawText("ADMIN LOGS", x, y, x+w, y+40, tocolor(255,120,120), 1.5, "default-bold", "center", "top")
    for i, log in ipairs(adminLogsData or {}) do
        local by = y+40 + (i-1)*26
        dxDrawText(os.date("%d/%m %H:%M", log.time).." | "..log.type.." | "..log.user.." | "..tostring(log.details), x+15, by, x+w-10, by+26, tocolor(255,220,220), 1, "default")
        if i > 12 then break end
    end
end
addEventHandler("onClientRender", root, drawAdminLogsPanel)
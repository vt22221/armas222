-- ForgeX Achievements Panel (Client-side)

local achievementsData = {}
local playerAchievements = {}
local isAchievementsVisible = false

addEvent("forgex:syncAchievements", true)
addEventHandler("forgex:syncAchievements", root, function(data)
    playerAchievements = data or {}
end)

bindKey("F2", "down", function()
    isAchievementsVisible = not isAchievementsVisible
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isAchievementsVisible and btn == "escape" and press then
        isAchievementsVisible = false
        cancelEvent()
    end
end)

function drawAchievementsPanel()
    if not isAchievementsVisible then return end
    local x, y, w, h = 170, 110, 520, 340
    dxDrawRectangle(x, y, w, h, tocolor(45,45,60,215))
    dxDrawText("CONQUISTAS", x, y, x+w, y+40, tocolor(255,255,140), 1.5, "default-bold", "center", "top")
    local idx = 0
    for id, ach in pairs(playerAchievements or {}) do
        local by = y+50 + idx*64
        dxDrawRectangle(x+18, by, w-36, 54, tocolor(60,60,80,170))
        dxDrawText(id, x+26, by+6, x+w-36, by+26, tocolor(200,255,180), 1, "default-bold")
        local status = ach.unlocked and "Desbloqueada!" or "Bloqueada"
        dxDrawText("Progresso: "..tostring(ach.progress or 0).." | "..status, x+26, by+28, x+w-36, by+48, tocolor(255,255,255), 0.95, "default")
        idx = idx + 1
        if idx > 4 then break end
    end
end
addEventHandler("onClientRender", root, drawAchievementsPanel)
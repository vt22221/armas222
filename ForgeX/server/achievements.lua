-- ForgeX Achievements System (Server-side)

local achievementsConfig = {
    ["firstkill"] = {desc="Primeiro abate!", reward="lootbox", goal=1},
    -- ...
}
local playerAchievements = {} -- [player] = { [id]={progress=0, unlocked=false, date="..."} }

addEvent("forgex:requestAchievements", true)
addEventHandler("forgex:requestAchievements", root, function()
    local plr = client
    if not playerAchievements[plr] then
        playerAchievements[plr] = {}
        for id,ach in pairs(achievementsConfig) do
            playerAchievements[plr][id] = {progress=0, unlocked=false, date=nil}
        end
    end
    triggerClientEvent(plr, "forgex:syncAchievements", plr, playerAchievements[plr])
end)

function fx_unlockAchievement(plr, id)
    local ach = playerAchievements[plr] and playerAchievements[plr][id]
    if not ach or ach.unlocked then return end
    ach.unlocked = true
    ach.date = os.date("%y/%m/%d")
    -- Dar prêmio
    fx_giveItem(plr, achievementsConfig[id].reward, 1)
    triggerClientEvent(plr, "forgex:achievementUnlocked", plr, achievementsConfig[id].desc)
    triggerClientEvent(plr, "forgex:syncAchievements", plr, playerAchievements[plr])
end
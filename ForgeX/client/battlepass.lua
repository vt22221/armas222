-- ForgeX Battle Pass (Client-side)

local battlepassData = nil
local playerBP = { level = 1, xp = 0, premium = false, claimed = {} }
local isBPVisible = false

addEvent("forgex:syncBattlePass", true)
addEventHandler("forgex:syncBattlePass", root, function(data, playerState)
    battlepassData = data
    playerBP = playerState
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestBattlePass", localPlayer)
end)

bindKey("F7", "down", function()
    isBPVisible = not isBPVisible
    if isBPVisible then
        triggerServerEvent("forgex:requestBattlePass", localPlayer)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isBPVisible and btn == "escape" and press then
        isBPVisible = false
        cancelEvent()
    end
end)

function drawBattlePass()
    if not isBPVisible or not battlepassData then return end
    local x, y, w, h = 120, 120, 700, 400
    dxDrawRectangle(x, y, w, h, tocolor(25,25,30,230))
    dxDrawText("BATTLE PASS", x, y, x+w, y+40, tocolor(255,215,0), 2, "default-bold", "center", "top")
    
    local levels = battlepassData.levels or {}
    local col = 0
    for i, levelInfo in ipairs(levels) do
        local bx = x+30 + (col%8)*80
        local by = y+60 + math.floor((col)/8)*110
        dxDrawRectangle(bx, by, 70, 100, tocolor(35,35,45,210))
        dxDrawText("Lv."..levelInfo.level, bx, by, bx+70, by+22, tocolor(255,255,190), 1.1, "default-bold", "center", "top")
        -- SVG ou fallback
        local svg = nil
        if levelInfo.reward_free and type(levelInfo.reward_free) == "string" then
            local weapon = tostring(levelInfo.reward_free):match("^(.-)|")
            if weapon then
                svg = getSVGImage("images/"..string.lower(weapon)..".svg", 44, 32)
            end
        end
        if svg then
            dxDrawImage(bx+13, by+28, 44, 32, svg)
        else
            dxDrawRectangle(bx+13, by+28, 44, 32, tocolor(50,50,60,160))
        end
        dxDrawText("Free: "..(levelInfo.reward_free or "-"), bx, by+62, bx+70, by+82, tocolor(180,255,180), 0.85, "default-bold", "center", "top")
        dxDrawText("Prem: "..(levelInfo.reward_premium or "-"), bx, by+82, bx+70, by+102, tocolor(255,220,140), 0.85, "default-bold", "center", "top")
        col = col + 1
    end
    dxDrawText("XP: "..playerBP.xp.." | Level: "..playerBP.level.." | Premium: "..(playerBP.premium and "Sim" or "Não"), x, y+h-35, x+w, y+h-5, tocolor(255,255,255), 1, "default", "center", "bottom")
end
addEventHandler("onClientRender", root, drawBattlePass)

addEventHandler("onClientClick", root, function(btn, state, x, y)
    if not isBPVisible or not battlepassData then return end
    -- Aqui pode implementar clique para coletar prêmio etc.
end)

addEvent("forgex:battlepassClaimed", true)
addEventHandler("forgex:battlepassClaimed", root, function(level)
    outputChatBox("Prêmio do nível "..tostring(level).." coletado!")
    triggerServerEvent("forgex:requestBattlePass", localPlayer)
end)
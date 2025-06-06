function drawXPBar(x,y,w,h,xp,xpNext)
    local perc = math.min(xp/xpNext,1)
    dxDrawRectangle(x,y,w,h,tocolor(30,30,30,200))
    dxDrawRectangle(x,y,w*perc,h,tocolor(50,200,60,230))
    dxDrawText(string.format("%d/%d XP",xp,xpNext),x,y,x+w,y+h,tocolor(255,255,255),1,"default-bold","center","center")
end

function drawLootboxAnimation(reward)
    -- Animação real de roleta, highlight, efeito sonoro, etc
end

-- Leaderboard (top XP, top kills, top skins raras)
function drawLeaderboard(x,y)
    -- Busque dados do server (triggerServerEvent/triggerClientEvent) e desenhe
end
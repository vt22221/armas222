-- ForgeX Collections System (Client-side) - SVG seguro

local collectionsData = {}
local playerCollections = {}
local isCollectionUIVisible = false
local selectedWeapon = nil
local svgSize = 48

addEvent("forgex:syncCollections", true)
addEventHandler("forgex:syncCollections", root, function(data, playerState)
    collectionsData = data or {}
    playerCollections = playerState or {}
    if not selectedWeapon or not collectionsData[selectedWeapon] then
        selectedWeapon = next(collectionsData)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestCollections", localPlayer)
end)

bindKey("F5", "down", function()
    isCollectionUIVisible = not isCollectionUIVisible
    if isCollectionUIVisible then
        triggerServerEvent("forgex:requestCollections", localPlayer)
        selectedWeapon = next(collectionsData)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isCollectionUIVisible and btn == "escape" and press then
        isCollectionUIVisible = false
        cancelEvent()
    end
end)

function drawCollectionsUI()
    if not isCollectionUIVisible then return end
    local x, y, w, h = 180, 120, 600, 350
    dxDrawRectangle(x, y, w, h, tocolor(35,35,40,220))
    dxDrawText("COLEÇÕES", x, y, x+w, y+40, tocolor(255,245,140), 1.5, "default-bold", "center", "top")
    local idx = 0
    for weapon, col in pairs(collectionsData) do
        local bx = x+30 + idx*170
        local by = y+55
        dxDrawRectangle(bx, by, 160, 250, tocolor(50,50,60,180))
        local svg = getSVGImage("images/"..string.lower(weapon)..".svg", svgSize, svgSize)
        if svg then
            dxDrawImage(bx+56, by+16, svgSize, svgSize, svg)
        else
            dxDrawText(weapon, bx+56, by+16, bx+56+svgSize, by+16+svgSize, tocolor(200,80,80), 1.1, "default-bold", "center", "center")
        end
        dxDrawText("Recompensa: "..(col.reward or "-"), bx, by+72, bx+160, by+92, tocolor(255,220,120), 0.9, "default-bold", "center", "top")
        for i, skin in ipairs(col.skins or {}) do
            local owned = playerCollections[weapon] and playerCollections[weapon].skins and playerCollections[weapon].skins[skin]
            dxDrawText(skin, bx+10, by+92+i*18, bx+150, by+92+i*18+16, owned and tocolor(120,255,120) or tocolor(255,130,130), 0.85, "default", "left", "top")
        end
        idx = idx + 1
        if idx >= 3 then break end
    end
end
addEventHandler("onClientRender", root, drawCollectionsUI)

addEvent("forgex:collectionClaimed", true)
addEventHandler("forgex:collectionClaimed", root, function(weapon, reward)
    outputChatBox("Recompensa de coleção: "..tostring(reward), 80,255,180)
    triggerServerEvent("forgex:requestCollections", localPlayer)
end)
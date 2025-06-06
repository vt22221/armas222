-- ForgeX Inventory Panel (Client-side) - Profissional e funcional

local isInventoryVisible = false
local inventoryData = {skins = {}, lootboxes = {}}
local selectedSkin = nil
local svgSize = 48

-- Recebe inventário do servidor
addEvent("forgex:syncInventory", true)
addEventHandler("forgex:syncInventory", root, function(data)
    inventoryData = data or {skins = {}, lootboxes = {}}
    selectedSkin = nil
end)

-- Atalho para abrir/fechar inventário
bindKey("F9", "down", function()
    isInventoryVisible = not isInventoryVisible
    showCursor(isInventoryVisible)
end)

-- Fecha inventário com ESC
addEventHandler("onClientKey", root, function(btn, press)
    if isInventoryVisible and btn == "escape" and press then
        isInventoryVisible = false
        showCursor(false)
        cancelEvent()
    end
end)

-- Utilitário: verifica se mouse está sobre área
function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local mx, my = getCursorPosition()
    local sx, sy = guiGetScreenSize()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

-- Renderização do painel de inventário
function drawInventoryPanel()
    if not isInventoryVisible then return end
    local x, y = 300, 200
    local w, h = 480, 340
    dxDrawRectangle(x, y, w, h, tocolor(24,24,24,235))
    dxDrawText("Inventário", x+20, y+12, x+w-20, y+40, tocolor(255,215,0), 1.4, "default-bold", "left", "top")
    dxDrawLine(x, y+44, x+w, y+44, tocolor(60,60,60,180), 2)

    -- Skins
    dxDrawText("Skins:", x+20, y+54, x+120, y+74, tocolor(200,200,200), 1, "default-bold", "left", "top")
    local offsetY = y + 80
    local col, row = 0, 0
    for skin, _ in pairs(inventoryData.skins) do
        local weapon = skin:match("^(.-)|")
        local svgPath = "client/images/"..string.lower(weapon or "ak47")..".svg"
        local bx = x + 20 + col * (svgSize + 22)
        local by = offsetY + row * (svgSize + 36)
        local isSelected = (selectedSkin == skin)
        local isHover = isMouseInPosition(bx-4, by-4, svgSize+8, svgSize+8)
        -- Borda de destaque
        if isSelected then
            dxDrawRectangle(bx-6, by-6, svgSize+12, svgSize+12, tocolor(255,215,0,200))
        elseif isHover then
            dxDrawRectangle(bx-6, by-6, svgSize+12, svgSize+12, tocolor(255,255,180,90))
        end
        dxDrawRectangle(bx-4, by-4, svgSize+8, svgSize+8, tocolor(60,60,60,180))
        if fileExists(svgPath) then
            dxDrawImage(bx, by, svgSize, svgSize, svgPath)
        else
            dxDrawText(weapon or "?", bx, by, bx+svgSize, by+svgSize, tocolor(200,80,80), 1.1, "default-bold", "center", "center")
        end
        dxDrawText(skin:gsub("|", " - "), bx, by+svgSize+2, bx+svgSize, by+svgSize+20, tocolor(230,230,230), 0.85, "default-bold", "center", "top")
        -- Tooltip ao passar mouse
        if isHover then
            dxDrawRectangle(bx, by-28, 120, 24, tocolor(30,30,30,220))
            dxDrawText("Clique para equipar", bx, by-28, bx+120, by-4, tocolor(255,255,180), 0.9, "default-bold", "center", "center")
        end
        col = col + 1
        if col >= 6 then col = 0 row = row + 1 end
    end

    -- Lootboxes (exemplo de expansão)
    dxDrawText("Lootboxes:", x+20, y+h-70, x+120, y+h-50, tocolor(200,200,200), 1, "default-bold", "left", "top")
    local lcol = 0
    for box, qtd in pairs(inventoryData.lootboxes or {}) do
        local bx = x + 20 + lcol * (svgSize + 22)
        local by = y+h-44
        dxDrawRectangle(bx-4, by-4, svgSize+8, svgSize+8, tocolor(60,60,60,180))
        local svgPath = "client/images/lootbox.svg"
        if fileExists(svgPath) then
            dxDrawImage(bx, by, svgSize, svgSize, svgPath)
        else
            dxDrawText("?", bx, by, bx+svgSize, by+svgSize, tocolor(200,80,80), 1.1, "default-bold", "center", "center")
        end
        dxDrawText(box.." x"..qtd, bx, by+svgSize+2, bx+svgSize, by+svgSize+20, tocolor(230,230,230), 0.85, "default-bold", "center", "top")
        lcol = lcol + 1
    end
end
addEventHandler("onClientRender", root, drawInventoryPanel)

-- Clique para equipar skin
addEventHandler("onClientClick", root, function(btn, state, x, y)
    if not isInventoryVisible or btn ~= "left" or state ~= "down" then return end
    local panelX, panelY = 300, 200
    local col, row = 0, 0
    for skin, _ in pairs(inventoryData.skins) do
        local bx = panelX + 20 + col * (svgSize + 22)
        local by = panelY + 80 + row * (svgSize + 36)
        if isMouseInPosition(bx-4, by-4, svgSize+8, svgSize+8) then
            selectedSkin = skin
            triggerServerEvent("forgex:equipSkin", resourceRoot, skin)
            break
        end
        col = col + 1
        if col >= 6 then col = 0 row = row + 1 end
    end
end)
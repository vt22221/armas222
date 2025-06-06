-- ForgeX Contracts System (Client-side)

local contractsData = {}
local playerContracts = {}
local isContractUIVisible = false

addEvent("forgex:syncContracts", true)
addEventHandler("forgex:syncContracts", root, function(data, playerState)
    contractsData = data or {}
    playerContracts = playerState or {}
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestContracts", localPlayer)
end)

bindKey("F3", "down", function()
    isContractUIVisible = not isContractUIVisible
    if isContractUIVisible then
        triggerServerEvent("forgex:requestContracts", localPlayer)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isContractUIVisible and btn == "escape" and press then
        isContractUIVisible = false
        cancelEvent()
    end
end)

function drawContractsUI()
    if not isContractUIVisible then return end
    local x, y, w, h = 160, 110, 540, 340
    dxDrawRectangle(x, y, w, h, tocolor(40,40,40,220))
    dxDrawText("CONTRATOS", x, y, x+w, y+40, tocolor(255,220,120), 1.4, "default-bold", "center", "top")
    local idx = 0
    for id, c in pairs(contractsData or {}) do
        local pc = playerContracts[id] or {}
        local by = y + 55 + idx * 90
        dxDrawRectangle(x+20, by, w-40, 80, tocolor(50,50,60,170))
        dxDrawText(c.desc or id, x+30, by+8, x+300, by+32, tocolor(255,255,255), 1, "default-bold")
        dxDrawText("Itens: "..table.concat(c.input or {}, ", "), x+30, by+32, x+300, by+54, tocolor(220,220,255), 0.95, "default")
        dxDrawText("Recompensa: "..(c.reward or ""), x+30, by+54, x+300, by+76, tocolor(220,255,180), 0.95, "default")
        local status = pc.completed and (pc.delivered and "Aguardando Resgate" or "Pronto para Entrega") or "Incompleto"
        dxDrawText("Status: "..status, x+350, by+25, x+w-40, by+55, tocolor(255,255,180), 1, "default")
        idx = idx + 1
        if idx > 2 then break end
    end
end
addEventHandler("onClientRender", root, drawContractsUI)
-- ForgeX Marketplace (Client-side) - SVG seguro

local marketList = {}
local isMarketVisible = false
local selectedIdx = 1
local announceHandlerActive = false
local svgSize = 44

addEvent("forgex:marketplaceSync", true)
addEventHandler("forgex:marketplaceSync", root, function(list)
    marketList = list or {}
    if selectedIdx > #marketList then selectedIdx = #marketList end
    if selectedIdx < 1 then selectedIdx = 1 end
end)

bindKey("F6", "down", function()
    isMarketVisible = not isMarketVisible
    if isMarketVisible then
        triggerServerEvent("forgex:marketplaceList", localPlayer)
    else
        if announceHandlerActive then
            removeCommandHandler("anunciar")
            announceHandlerActive = false
        end
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if not isMarketVisible or not press then return end
    if btn == "arrow_u" then
        selectedIdx = math.max(1, selectedIdx - 1)
        cancelEvent()
    elseif btn == "arrow_d" then
        selectedIdx = math.min(#marketList, selectedIdx + 1)
        cancelEvent()
    elseif btn == "a" then
        showSellDialog()
        cancelEvent()
    elseif btn == "escape" then
        isMarketVisible = false
        if announceHandlerActive then
            removeCommandHandler("anunciar")
            announceHandlerActive = false
        end
        cancelEvent()
    end
end)

function drawMarketplace()
    if not isMarketVisible then return end
    local x, y, w, h = 150, 120, 600, 400
    dxDrawRectangle(x, y, w, h, tocolor(30,30,40,230))
    dxDrawText("MARKETPLACE", x, y, x+w, y+35, tocolor(100,220,255), 1.6, "default-bold", "center", "top")
    local startY = y + 50
    for i, offer in ipairs(marketList) do
        local by = startY + (i-1)*56
        if i == selectedIdx then
            dxDrawRectangle(x+8, by, w-16, 54, tocolor(60,80,180,128))
        else
            dxDrawRectangle(x+8, by, w-16, 54, tocolor(45,45,60,90))
        end
        local weapon = offer.skin:match("^(.-)|")
        local svg = getSVGImage("images/"..string.lower(weapon or "ak47")..".svg", svgSize, svgSize)
        if svg then
            dxDrawImage(x+16, by+6, svgSize, svgSize, svg)
        else
            dxDrawText(weapon or "?", x+16, by+6, x+16+svgSize, by+6+svgSize, tocolor(200,80,80), 1.1, "default-bold", "center", "center")
        end
        dxDrawText(offer.skin.." | "..offer.price.."$", x+80, by+10, x+w-130, by+35, tocolor(255,255,255), 1, "default-bold", "left", "top")
        dxDrawText("Vendedor: "..offer.seller, x+80, by+32, x+w-130, by+50, tocolor(180,220,255), 0.85, "default-bold", "left", "top")
    end
end
addEventHandler("onClientRender", root, drawMarketplace)

function showSellDialog()
    if announceHandlerActive then removeCommandHandler("anunciar") end
    announceHandlerActive = true
    outputChatBox("Digite: /anunciar [skin] [preço]", 100,255,220)
    addCommandHandler("anunciar", function(_, s, p)
        if not s or not p then
            outputChatBox("/anunciar [skin] [preço]", 255,255,80)
            return
        end
        local price = tonumber(p)
        if not price or price < 1 then
            outputChatBox("Preço inválido.", 255,100,100)
            return
        end
        triggerServerEvent("forgex:marketplaceSell", localPlayer, s, price)
        removeCommandHandler("anunciar")
        announceHandlerActive = false
    end)
end
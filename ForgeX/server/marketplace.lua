-- ForgeX Marketplace System (Server-side)
local marketList = {} -- { {id=1, seller=playerName, skin="AK-47|Redline", price=5000} }
local offerId = 1

function syncMarketplaceAll()
    for _,plr in ipairs(getElementsByType("player")) do
        triggerClientEvent(plr, "forgex:marketplaceSync", plr, marketList)
    end
end

addEvent("forgex:marketplaceList", true)
addEventHandler("forgex:marketplaceList", root, function()
    triggerClientEvent(client, "forgex:marketplaceSync", client, marketList)
end)

addEvent("forgex:marketplaceSell", true)
addEventHandler("forgex:marketplaceSell", root, function(skin, price)
    local inv = playerInventories[client]
    if not inv or not inv.skins[skin] then
        triggerClientEvent(client, "forgex:marketplaceSync", client, marketList)
        return
    end
    -- Checar se já está a venda
    for _,item in ipairs(marketList) do
        if item.skin == skin and item.seller == getPlayerName(client) then
            triggerClientEvent(client, "forgex:inventoryFeedback", client, "Você já anunciou essa skin.")
            return
        end
    end
    -- Remover do inventário
    inv.skins[skin] = nil
    table.insert(marketList, {id=offerId, seller=getPlayerName(client), skin=skin, price=tonumber(price)})
    offerId = offerId + 1
    syncMarketplaceAll()
end)

addEvent("forgex:marketplaceBuy", true)
addEventHandler("forgex:marketplaceBuy", root, function(id)
    id = tonumber(id)
    for i,item in ipairs(marketList) do
        if item.id == id then
            local buyer = client
            if item.seller == getPlayerName(buyer) then
                triggerClientEvent(buyer, "forgex:inventoryFeedback", buyer, "Você não pode comprar sua própria skin.")
                return
            end
            -- Checar saldo
            local money = getPlayerMoney(buyer)
            if money < item.price then
                triggerClientEvent(buyer, "forgex:inventoryFeedback", buyer, "Saldo insuficiente.")
                return
            end
            -- Transferência
            takePlayerMoney(buyer, item.price)
            for _,plr in ipairs(getElementsByType("player")) do
                if getPlayerName(plr) == item.seller then
                    givePlayerMoney(plr, item.price)
                    break
                end
            end
            -- Dar skin
            local inv = playerInventories[buyer]
            inv.skins[item.skin] = true
            table.remove(marketList, i)
            syncMarketplaceAll()
            return
        end
    end
    triggerClientEvent(client, "forgex:inventoryFeedback", client, "Anúncio não encontrado.")
end)
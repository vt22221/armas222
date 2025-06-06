-- ForgeX Inventory System (Server-side)
-- Controla inventário de skins, lootboxes e consumíveis

local playerInventories = {} -- [player] = { skins = {["AK-47|Redline"]=true,...}, lootboxes = {["classic"]=3,...} }

-- Carrega inventário do player ao conectar
addEventHandler("onPlayerLogin", root, function()
    local acc = getPlayerAccount(source)
    if not acc or isGuestAccount(acc) then return end
    local invData = getAccountData(acc, "fx:inventory")
    if invData then
        playerInventories[source] = fromJSON(invData)
    else
        playerInventories[source] = {skins={}, lootboxes={}}
    end
    triggerClientEvent(source, "forgex:syncInventory", source, playerInventories[source])
end)

-- Salva inventário ao sair
addEventHandler("onPlayerQuit", root, function()
    local acc = getPlayerAccount(source)
    if not acc or isGuestAccount(acc) then return end
    local data = playerInventories[source] or {skins={}, lootboxes={}}
    setAccountData(acc, "fx:inventory", toJSON(data))
    playerInventories[source] = nil
end)

-- Aplicar skin
addEvent("forgex:applySkin", true)
addEventHandler("forgex:applySkin", root, function(weapon, skin)
    if not weapon or not skin then return end
    local inv = playerInventories[client]
    if not inv or not inv.skins[skin] then
        triggerClientEvent(client, "forgex:inventoryFeedback", client, "Você não possui esta skin.")
        return
    end
    -- Aplicar a skin (armazenar em accountData, variável, etc)
    setElementData(client, "fx:skin:"..weapon, skin)
    triggerClientEvent(client, "forgex:inventoryFeedback", client, "Skin aplicada com sucesso!")
end)

-- Usar lootbox
addEvent("forgex:useLootbox", true)
addEventHandler("forgex:useLootbox", root, function(boxType)
    if not boxType then return end
    local inv = playerInventories[client]
    if not inv or not inv.lootboxes[boxType] or inv.lootboxes[boxType] < 1 then
        triggerClientEvent(client, "forgex:inventoryFeedback", client, "Você não possui esta lootbox.")
        return
    end
    -- Sorteio do prêmio
    local prize = getRandomLootboxPrize(boxType)
    if prize then
        inv.skins[prize] = true
        inv.lootboxes[boxType] = inv.lootboxes[boxType] - 1
        triggerClientEvent(client, "forgex:lootboxOpened", client, boxType, prize)
        triggerClientEvent(client, "forgex:syncInventory", client, inv)
    else
        triggerClientEvent(client, "forgex:inventoryFeedback", client, "Erro ao abrir lootbox.")
    end
end)

-- Função utilitária: sorteio de lootbox
function getRandomLootboxPrize(boxType)
    -- Exemplo: definir tabelas reais de lootbox!
    local tableClassic = {"AK-47|Redline", "M4A1|Asiimov", "AWP|Dragon Lore"}
    if boxType == "classic" then
        return tableClassic[math.random(#tableClassic)]
    end
    return nil
end

-- Dar item ao player (admin, reward, etc)
function fx_giveItem(player, item, amount)
    if not isElement(player) then return false end
    local inv = playerInventories[player]
    if not inv then return false end
    if item:find("|") then
        inv.skins[item] = true
    else
        inv.lootboxes[item] = (inv.lootboxes[item] or 0) + (amount or 1)
    end
    triggerClientEvent(player, "forgex:syncInventory", player, inv)
    return true
end

-- Comando admin para dar skin/lootbox
addCommandHandler("giveitem", function(plr, cmd, target, item, amount)
    if getElementData(plr, "admin") ~= true then return end
    local tgt = getPlayerFromName(target)
    if tgt and item then
        fx_giveItem(tgt, item, tonumber(amount) or 1)
        outputChatBox("Item dado.", plr)
    end
end)
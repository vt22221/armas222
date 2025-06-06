--[[
ForgeX Gift Code System
- Admin gera códigos promocoionais para recompensas (lootbox, skin, cash, título, etc)
- Jogador pode usar código uma vez
- Persistência total, integração com o núcleo
]]

-- Criação da tabela de giftcodes (executar só uma vez)
addEventHandler("onResourceStart", resourceRoot, function()
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS giftcodes (code TEXT PRIMARY KEY, reward TEXT, usedby TEXT)")
end)

-- Adicionar giftcode novo (admin)
function addGiftCode(code, reward)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO giftcodes (code, reward, usedby) VALUES (?, ?, ?)", code, toJSON(reward), toJSON({}))
end

-- Jogador usa código
addEvent("forgex:useGiftCode", true)
addEventHandler("forgex:useGiftCode", root, function(code)
    local acc = getAccountName(getPlayerAccount(client))
    local qh = dbQuery(ForgeXDB.db, "SELECT reward, usedby FROM giftcodes WHERE code=?", code)
    local result = dbPoll(qh, -1)
    if not result or not result[1] then
        triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Código inválido.", 255,60,60)
        return
    end
    local reward = fromJSON(result[1].reward)
    local usedby = fromJSON(result[1].usedby)
    for _,v in ipairs(usedby) do
        if v == acc then
            triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Você já usou este código.", 255,140,60)
            return
        end
    end
    -- Dá a recompensa
    if reward.type == "lootbox" then
        ForgeXDB.addLootbox(acc, reward.value, reward.amount or 1)
    elseif reward.type == "skin" then
        ForgeXDB.addPlayerSkin(acc, reward.value)
    elseif reward.type == "cash" then
        ForgeXDB.giveMoney(acc, reward.amount or 1000)
    elseif reward.type == "title" then
        ForgeXDB.unlockTitle(acc, reward.value)
    end
    table.insert(usedby, acc)
    dbExec(ForgeXDB.db, "UPDATE giftcodes SET usedby=? WHERE code=?", toJSON(usedby), code)
    triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Código resgatado com sucesso!", 80,255,80)
    triggerEvent("forgex:syncInventory", client)
end)

-- Comando de admin para criar código (exemplo: /giftcode gold2025 lootbox rare 2)
addCommandHandler("giftcode", function(plr, _, code, type, value, amount)
    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then
        local reward = {type=type, value=value, amount=tonumber(amount)}
        addGiftCode(code, reward)
        outputChatBox("Giftcode criado!", plr, 80,255,80)
    end
end)
--[[
ForgeX Server Main - Núcleo
- Carrega JSONs de configuração
- Sincroniza dados com o client
- Gerencia eventos principais: compra, equipar, lootbox, upgrades, etc
- Integra módulos extras
]]

local skinsList, lootboxList, upgradesList, shopList = {}, {}, {}, {}

function fileGetContents(path)
    local f = fileOpen(path)
    if not f then return nil end
    local data = fileRead(f, fileGetSize(f))
    fileClose(f)
    return data
end

addEventHandler("onResourceStart", resourceRoot, function()
    skinsList = fromJSON(fileGetContents("data/skins.json") or "{}")
    lootboxList = fromJSON(fileGetContents("data/lootboxes.json") or "{}")
    upgradesList = fromJSON(fileGetContents("data/upgrades.json") or "{}")
    shopList = fromJSON(fileGetContents("data/shop.json") or "{}")
    ForgeXDB.init()
    -- Iniciar módulos extras aqui, se necessário
end)

addEventHandler("onPlayerLogin", root, function()
    triggerEvent("forgex:syncInventory", source)
end)

addEvent("forgex:shopBuyItem", true)
addEventHandler("forgex:shopBuyItem", root, function(itemType, itemName)
    local acc = getAccountName(getPlayerAccount(client))
    local item
    for _,it in ipairs(shopList) do if it.type==itemType and it.name==itemName then item=it break end end
    if not item then return end
    local money = ForgeXDB.getPlayerMoney(acc)
    if money < item.price then
        triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Dinheiro insuficiente!",255,0,0)
        return
    end
    ForgeXDB.giveMoney(acc, -item.price)
    if itemType=="skin" then
        ForgeXDB.addPlayerSkin(acc, itemName)
    elseif itemType=="lootbox" then
        ForgeXDB.addLootbox(acc, itemName, 1)
    elseif itemType=="upgrade" then
        ForgeXDB.upgradeWeapon(acc, 355, upgradesList)
    end
    triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Compra realizada!", 0,255,120)
    triggerEvent("forgex:syncInventory", client)
end)

addEvent("forgex:giveSkinToPlayer", true)
addEventHandler("forgex:giveSkinToPlayer", root, function(skin)
    local acc = getAccountName(getPlayerAccount(client))
    ForgeXDB.setEquippedSkin(acc, skin)
    triggerClientEvent(client, "forgex:updateSkin", resourceRoot, skin)
end)

addEvent("forgex:removeSkinFromPlayer", true)
addEventHandler("forgex:removeSkinFromPlayer", root, function(skin)
    local acc = getAccountName(getPlayerAccount(client))
    ForgeXDB.setEquippedSkin(acc, "ak47_default")
    triggerClientEvent(client, "forgex:updateSkin", resourceRoot, "ak47_default")
end)

addEvent("forgex:openLootbox", true)
addEventHandler("forgex:openLootbox", root, function(boxType)
    local acc = getAccountName(getPlayerAccount(client))
    if not ForgeXDB.hasLootbox(acc, boxType) then
        triggerClientEvent(client, "forgex:showNotification", resourceRoot, "Você não possui lootbox deste tipo.", 255,60,60)
        return
    end
    ForgeXDB.addLootbox(acc, boxType, -1)
    local pool, total = {}, 0
    for rarity, arr in pairs(lootboxList[boxType].rewards) do
        for _, def in ipairs(arr) do
            table.insert(pool, {def.type,def.key,rarity,def.chance or 0})
            total = total + (def.chance or 0)
        end
    end
    local pick = math.random(1, total)
    local sum = 0
    local reward
    for _,r in ipairs(pool) do sum=sum+r[4] if pick<=sum then reward=r break end end
    if reward[1]=="skin" then ForgeXDB.addPlayerSkin(acc, reward[2]) end
    triggerClientEvent(client,"forgex:showNotification",resourceRoot,"Você ganhou: "..reward[2],255,215,0)
    triggerEvent("forgex:syncInventory",client)
end)

addEvent("forgex:syncInventory", true)
addEventHandler("forgex:syncInventory", root, function()
    local acc = getAccountName(getPlayerAccount(source))
    local skins = ForgeXDB.getPlayerSkins(acc)
    local lootboxes = ForgeXDB.getPlayerLootboxes(acc)
    local cash = ForgeXDB.getPlayerMoney(acc)
    local upgrades = ForgeXDB.getPlayerUpgrades(acc)
    -- Envie dados extras conforme módulos extras!
    triggerClientEvent(source,"forgex:sendFullData",resourceRoot,skins,lootboxes,cash,upgrades,shopList,lootboxList,skinsList,upgradesList)
end)
-- ForgeX Lootbox System (Server-side)
-- (Caso inventário não centralize lootbox)

addEvent("forgex:useLootbox", true)
addEventHandler("forgex:useLootbox", root, function(boxType)
    local inv = playerInventories[client]
    if not inv or not inv.lootboxes[boxType] or inv.lootboxes[boxType] < 1 then
        triggerClientEvent(client, "forgex:inventoryFeedback", client, "Você não possui esta lootbox.")
        return
    end
    -- Anti-spam
    if getElementData(client, "fx:lootbox_cooldown") and getTickCount() - getElementData(client, "fx:lootbox_cooldown") < 2000 then
        triggerClientEvent(client, "forgex:inventoryFeedback", client, "Aguarde para abrir outra lootbox.")
        return
    end
    setElementData(client, "fx:lootbox_cooldown", getTickCount())
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
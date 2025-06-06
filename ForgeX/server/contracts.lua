-- ForgeX Contracts System (Server-side)

local contractsConfig = {
    ["ak_contract"] = {type="skin", input={"AK-47|Redline","AK-47|Vulcan"}, output="lootbox", reward="lootbox"}
}
local playerContracts = {} -- [player] = { [id]={progress=0, completed=false, delivered=false} }

addEvent("forgex:requestContracts", true)
addEventHandler("forgex:requestContracts", root, function()
    local plr = client
    if not playerContracts[plr] then
        playerContracts[plr] = {}
        for id in pairs(contractsConfig) do
            playerContracts[plr][id] = {progress=0, completed=false, delivered=false}
        end
    end
    -- Atualizar progresso
    for id,conf in pairs(contractsConfig) do
        local state = playerContracts[plr][id]
        state.progress = 0; state.completed = true
        for _,skin in ipairs(conf.input) do
            if not playerInventories[plr] or not playerInventories[plr].skins[skin] then
                state.completed = false
            else
                state.progress = state.progress + 1
            end
        end
    end
    triggerClientEvent(plr, "forgex:syncContracts", plr, contractsConfig, playerContracts[plr])
end)

addEvent("forgex:deliverContractItems", true)
addEventHandler("forgex:deliverContractItems", root, function(id)
    local plr = client
    local state = playerContracts[plr][id]
    local conf = contractsConfig[id]
    if not state or not conf then return end
    if state.completed and not state.delivered then
        -- Remover itens
        for _,skin in ipairs(conf.input) do
            if playerInventories[plr] and playerInventories[plr].skins[skin] then
                playerInventories[plr].skins[skin] = nil
            end
        end
        state.delivered = true
        triggerClientEvent(plr, "forgex:contractFeedback", plr, "Itens entregues! Resgate sua recompensa.")
    else
        triggerClientEvent(plr, "forgex:contractFeedback", plr, "Contrato incompleto ou já entregue.")
    end
end)

addEvent("forgex:claimContractReward", true)
addEventHandler("forgex:claimContractReward", root, function(id)
    local plr = client
    local state = playerContracts[plr][id]
    local conf = contractsConfig[id]
    if not state or not conf then return end
    if state.delivered then
        fx_giveItem(plr, conf.reward, 1)
        state.delivered = false
        state.completed = false
        triggerClientEvent(plr, "forgex:contractFeedback", plr, "Recompensa entregue!")
    else
        triggerClientEvent(plr, "forgex:contractFeedback", plr, "Entregue os itens primeiro.")
    end
end)
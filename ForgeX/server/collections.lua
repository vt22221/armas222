-- ForgeX Collections System (Server-side)

local collectionsData = {
    ["AK-47"] = { reward="AK-47|Gold", skins={"AK-47|Redline", "AK-47|Vulcan"} }
    -- ...
}
local playerCollections = {} -- [player] = { [weapon]={skins={[skin]=true,...}, completed=bool, claimed=bool} }

addEvent("forgex:requestCollections", true)
addEventHandler("forgex:requestCollections", root, function()
    local plr = client
    if not playerCollections[plr] then playerCollections[plr] = {} end
    -- Atualizar progresso
    for weapon, col in pairs(collectionsData) do
        if not playerCollections[plr][weapon] then playerCollections[plr][weapon] = {skins={}, completed=false, claimed=false} end
        local state = playerCollections[plr][weapon]
        state.completed = true
        for _,skin in ipairs(col.skins) do
            if not playerInventories[plr] or not playerInventories[plr].skins[skin] then
                state.completed = false
            else
                state.skins[skin] = true
            end
        end
    end
    triggerClientEvent(plr, "forgex:syncCollections", plr, collectionsData, playerCollections[plr])
end)

addEvent("forgex:claimCollectionReward", true)
addEventHandler("forgex:claimCollectionReward", root, function(weapon)
    local plr = client
    local state = playerCollections[plr][weapon]
    local col = collectionsData[weapon]
    if not state or not col then return end
    if not state.completed or state.claimed then
        triggerClientEvent(plr, "forgex:collectionClaimed", plr, weapon, "Já resgatado ou não completo.")
        return
    end
    -- Dar prêmio
    fx_giveItem(plr, col.reward, 1)
    state.claimed = true
    triggerClientEvent(plr, "forgex:collectionClaimed", plr, weapon, col.reward)
end)
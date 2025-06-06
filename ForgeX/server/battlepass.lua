--[[
ForgeX Battle Pass System
- Níveis, XP, recompensas, premium
- Progresso e coleta persistente
- Funções e eventos reais para XP e recompensas
]]

-- Carregue a configuração do battlepass
local bpConfig = fromJSON(fileGetContents("data/battlepass.json") or "{}")
local bpLevels = bpConfig.levels or {}

function getPlayerBattlePass(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM battlepass WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return (result and result[1] and fromJSON(result[1].json)) or {level=1, xp=0, premium=false, claimed={}}
end

function savePlayerBattlePass(acc, data)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO battlepass VALUES (?,?)", acc, toJSON(data))
end

function addBattlePassXP(acc, amount)
    local bp = getPlayerBattlePass(acc)
    bp.xp = (bp.xp or 0) + amount
    local lvl = bp.level or 1
    local nextLvl = bpLevels[lvl+1]
    while nextLvl and bp.xp >= nextLvl.xp do
        bp.level = lvl + 1
        lvl = bp.level
        triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass: Nível "..lvl.." alcançado!", 225,180,60)
        nextLvl = bpLevels[lvl+1]
    end
    savePlayerBattlePass(acc, bp)
end

function claimBattlePassReward(acc, level)
    local bp = getPlayerBattlePass(acc)
    if not bp.claimed then bp.claimed = {} end
    if (bp.level or 1) < level or bp.claimed[level] then return end
    local reward = bpLevels[level] and bpLevels[level].reward or nil
    if not reward then return end
    if reward.premium and not bp.premium then return end
    if reward.lootbox then ForgeXDB.addLootbox(acc, reward.lootbox, 1) end
    if reward.skin then ForgeXDB.addPlayerSkin(acc, reward.skin) end
    if reward.cash then ForgeXDB.giveMoney(acc, reward.cash) end
    bp.claimed[level] = true
    savePlayerBattlePass(acc, bp)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass: Recompensa do nível "..level.." coletada!", 225,200,20)
    triggerEvent("forgex:syncInventory", getPlayerFromAccount(acc))
end

function setBattlePassPremium(acc)
    local bp = getPlayerBattlePass(acc)
    if bp.premium then return end
    bp.premium = true
    savePlayerBattlePass(acc, bp)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass Premium ativado!", 255,215,40)
end

-- EVENTOS reais para XP, recompensa, premium
addEvent("forgex:battlepassAddXP", true)
addEventHandler("forgex:battlepassAddXP", root, function(xp)
    local acc = getAccountName(getPlayerAccount(client))
    addBattlePassXP(acc, xp)
end)

addEvent("forgex:claimBattlePassReward", true)
addEventHandler("forgex:claimBattlePassReward", root, function(level)
    local acc = getAccountName(getPlayerAccount(client))
    claimBattlePassReward(acc, level)
end)

addEvent("forgex:battlepassPremium", true)
addEventHandler("forgex:battlepassPremium", root, function()
    local acc = getAccountName(getPlayerAccount(client))
    setBattlePassPremium(acc)
end)

-- Integração com missões/conquistas: chame addBattlePassXP(acc, valor) ao completar missões, conquistas, etc.
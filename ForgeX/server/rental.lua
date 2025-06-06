--[[
ForgeX Skin Rental/Evolution System
- Skins temporárias: aluguel de skins por tempo limitado
- Suporte a evolução: upgradeando a skin durante o aluguel
- Renovação automática/por comando, persistência total
]]

-- Criação da tabela de aluguel (executar só uma vez)
addEventHandler("onResourceStart", resourceRoot, function()
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS rentals (acc TEXT, skin TEXT, expires INTEGER, level INTEGER, PRIMARY KEY (acc,skin))")
end)

-- Alugar uma skin por X horas
function rentSkin(acc, skin, hours)
    local now = getRealTime().timestamp
    local expires = now + (hours*3600)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO rentals (acc,skin,expires,level) VALUES (?,?,?,?)", acc, skin, expires, 1)
    ForgeXDB.addPlayerSkin(acc, skin, true) -- true = temporária
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Skin "..skin.." alugada por "..hours.."h!", 80,255,255)
end

-- Checa skins expiradas e remove
function checkExpiredRentals()
    local now = getRealTime().timestamp
    local qh = dbQuery(ForgeXDB.db, "SELECT * FROM rentals WHERE expires<=?", now)
    local result = dbPoll(qh, -1)
    for _,v in ipairs(result or {}) do
        ForgeXDB.removePlayerSkin(v.acc, v.skin, true)
        dbExec(ForgeXDB.db, "DELETE FROM rentals WHERE acc=? AND skin=?", v.acc, v.skin)
        local plr = getPlayerFromAccount(v.acc)
        if plr then
            triggerClientEvent(plr, "forgex:showNotification", resourceRoot, "Sua skin temporária "..v.skin.." expirou.", 255,100,60)
        end
    end
end
setTimer(checkExpiredRentals, 15*60*1000, 0) -- a cada 15min

-- Evoluir uma skin alugada (level up)
function evolveRentalSkin(acc, skin)
    local qh = dbQuery(ForgeXDB.db, "SELECT level,expires FROM rentals WHERE acc=? AND skin=?", acc, skin)
    local result = dbPoll(qh, -1)
    if not result or not result[1] then return false, "Skin não alugada." end
    local level = math.min((result[1].level or 1) + 1, 5)
    dbExec(ForgeXDB.db, "UPDATE rentals SET level=? WHERE acc=? AND skin=?", level, acc, skin)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Skin "..skin.." evoluída! Nível "..level..".", 80,255,80)
    return true
end

-- Renovar aluguel da skin
function renewRentalSkin(acc, skin, hours)
    local qh = dbQuery(ForgeXDB.db, "SELECT expires FROM rentals WHERE acc=? AND skin=?", acc, skin)
    local result = dbPoll(qh, -1)
    if not result or not result[1] then return false, "Skin não alugada." end
    local now = getRealTime().timestamp
    local expires = math.max(result[1].expires, now) + (hours*3600)
    dbExec(ForgeXDB.db, "UPDATE rentals SET expires=? WHERE acc=? AND skin=?", expires, acc, skin)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Aluguel renovado por "..hours.."h.", 80,255,255)
    return true
end

-- Consulta todas skins alugadas e nível
function getPlayerRentals(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT skin,expires,level FROM rentals WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    local out = {}
    for _,v in ipairs(result or {}) do
        out[v.skin] = {expires=v.expires, level=v.level}
    end
    return out
end

-- Eventos para comandos UI/server
addEvent("forgex:rentSkin", true)
addEventHandler("forgex:rentSkin", root, function(skin, hours)
    local acc = getAccountName(getPlayerAccount(client))
    rentSkin(acc, skin, hours)
end)

addEvent("forgex:evolveRentalSkin", true)
addEventHandler("forgex:evolveRentalSkin", root, function(skin)
    local acc = getAccountName(getPlayerAccount(client))
    evolveRentalSkin(acc, skin)
end)

addEvent("forgex:renewRentalSkin", true)
addEventHandler("forgex:renewRentalSkin", root, function(skin, hours)
    local acc = getAccountName(getPlayerAccount(client))
    renewRentalSkin(acc, skin, hours)
end)
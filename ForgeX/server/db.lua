--[[ 
ForgeXDB - Banco de dados persistente multi-feature
Cada tabela armazena:
- skins, lootboxes, upgrades, dinheiro, títulos, battlepass, contratos, XP de armas, conquistas, aluguel, ranks, etc
- Modular: adicione campos e funções conforme módulos extras
]]

ForgeXDB = {}

function ForgeXDB.init()
    ForgeXDB.db = dbConnect("sqlite", "forgex.db")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS skins (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS lootboxes (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS upgrades (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS cash (acc TEXT PRIMARY KEY, amount INTEGER)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS equipped (acc TEXT PRIMARY KEY, skin TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS titles (acc TEXT PRIMARY KEY, titles TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS equipped_title (acc TEXT PRIMARY KEY, title TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS battlepass (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS contracts (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS weaponxp (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS achievements (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS rental_skins (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS skinlevel (acc TEXT PRIMARY KEY, json TEXT)")
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS ranks (acc TEXT PRIMARY KEY, rank INTEGER)")
end

-- Skins
function ForgeXDB.getPlayerSkins(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM skins WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return (result and result[1] and fromJSON(result[1].json)) or {ak47_default=true}
end

function ForgeXDB.addPlayerSkin(acc, skin)
    local list = ForgeXDB.getPlayerSkins(acc)
    list[skin] = true
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO skins VALUES (?,?)", acc, toJSON(list))
end

function ForgeXDB.removePlayerSkin(acc, skin)
    local list = ForgeXDB.getPlayerSkins(acc)
    list[skin] = nil
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO skins VALUES (?,?)", acc, toJSON(list))
end

-- Lootboxes
function ForgeXDB.getPlayerLootboxes(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM lootboxes WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return (result and result[1] and fromJSON(result[1].json)) or {}
end

function ForgeXDB.addLootbox(acc, box, amt)
    local list = ForgeXDB.getPlayerLootboxes(acc)
    list[box] = (list[box] or 0) + amt
    if list[box] <= 0 then list[box]=nil end
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO lootboxes VALUES (?,?)", acc, toJSON(list))
end

function ForgeXDB.hasLootbox(acc, box)
    local list = ForgeXDB.getPlayerLootboxes(acc)
    return list[box] and list[box]>0
end

-- Upgrades
function ForgeXDB.getPlayerUpgrades(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM upgrades WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return (result and result[1] and fromJSON(result[1].json)) or {ak47=1}
end

function ForgeXDB.upgradeWeapon(acc, weaponName, upgradesList)
    -- upgradesList deve ser passado pelo server/main.lua para saber o máximo
    local list = ForgeXDB.getPlayerUpgrades(acc)
    local cur = list[weaponName] or 1
    local maxLvl = #(upgradesList[weaponName] and upgradesList[weaponName].levels or {1})
    if cur < maxLvl then
        list[weaponName] = cur + 1
        dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO upgrades VALUES (?,?)", acc, toJSON(list))
        return true, cur+1
    end
    return false, cur
end

-- Dinheiro
function ForgeXDB.getPlayerMoney(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT amount FROM cash WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return result and result[1] and tonumber(result[1].amount) or 2000
end

function ForgeXDB.giveMoney(acc, amt)
    local current = ForgeXDB.getPlayerMoney(acc)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO cash VALUES (?,?)", acc, current+amt)
end

-- Equipped skin
function ForgeXDB.setEquippedSkin(acc, skin)
    dbExec(ForgeXDB.db,"INSERT OR REPLACE INTO equipped VALUES (?,?)", acc, skin)
end

function ForgeXDB.getEquippedSkin(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT skin FROM equipped WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return result and result[1] and result[1].skin or "ak47_default"
end

-- Titles
function ForgeXDB.unlockTitle(acc, title)
    local qh = dbQuery(ForgeXDB.db, "SELECT titles FROM titles WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    local all = (result and result[1] and fromJSON(result[1].titles)) or {}
    all[title] = true
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO titles VALUES (?,?)", acc, toJSON(all))
end

function ForgeXDB.getTitles(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT titles FROM titles WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return (result and result[1] and fromJSON(result[1].titles)) or {}
end

function ForgeXDB.setEquippedTitle(acc, title)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO equipped_title VALUES (?,?)", acc, title)
end

function ForgeXDB.getEquippedTitle(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT title FROM equipped_title WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return result and result[1] and result[1].title or nil
end

-- XP de arma
function ForgeXDB.getWeaponXP(acc, weapon)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM weaponxp WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    local all = (result and result[1] and fromJSON(result[1].json)) or {}
    return all[weapon] or 0
end

function ForgeXDB.addWeaponXP(acc, weapon, xp)
    local qh = dbQuery(ForgeXDB.db, "SELECT json FROM weaponxp WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    local all = (result and result[1] and fromJSON(result[1].json)) or {}
    all[weapon] = (all[weapon] or 0) + xp
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO weaponxp VALUES (?,?)", acc, toJSON(all))
end

-- Ranks
function ForgeXDB.getRank(acc)
    local qh = dbQuery(ForgeXDB.db, "SELECT rank FROM ranks WHERE acc=?", acc)
    local result = dbPoll(qh, -1)
    return result and result[1] and tonumber(result[1].rank) or 1000
end

function ForgeXDB.setRank(acc, newRank)
    dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO ranks VALUES (?,?)", acc, newRank)
end

-- Outros métodos conforme módulos extras...
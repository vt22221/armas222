-- ForgeX Ranked System (Server-side)

local rankedData = {} -- [player] = {elo=1000, division="Bronze", history={...}}
local leaderboard = {} -- atualizado conforme necessário

local divisions = {
    {min=0, max=999, name="Bronze"},
    {min=1000, max=1299, name="Prata"},
    {min=1300, max=1599, name="Ouro"},
    {min=1600, max=1999, name="Diamante"},
    {min=2000, max=9999, name="Elite"}
}

function getDivision(elo)
    for _,d in ipairs(divisions) do
        if elo >= d.min and elo <= d.max then return d.name end
    end
    return "Bronze"
end

addEvent("forgex:requestRanked", true)
addEventHandler("forgex:requestRanked", root, function()
    local plr = client
    if not rankedData[plr] then
        rankedData[plr] = {elo=1000, division="Bronze", history={}}
    end
    -- Atualizar divisão
    rankedData[plr].division = getDivision(rankedData[plr].elo)
    -- Leaderboard
    leaderboard = {}
    for p,data in pairs(rankedData) do
        table.insert(leaderboard, {player=getPlayerName(p), elo=data.elo, division=data.division})
    end
    table.sort(leaderboard, function(a,b) return a.elo > b.elo end)
    local top10 = {}
    for i=1,math.min(10,#leaderboard) do table.insert(top10, leaderboard[i]) end
    triggerClientEvent(plr, "forgex:syncRanked", plr, {elo=rankedData[plr].elo, division=rankedData[plr].division, history=rankedData[plr].history, leaderboard=top10})
end)

-- Exemplo de função para registrar resultado de partida
function fx_rankedMatch(plr, result)
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    local change = (result=="win" and 30) or (result=="lose" and -20) or 0
    rankedData[plr].elo = math.max(0, rankedData[plr].elo + change)
    local oldDiv = rankedData[plr].division
    rankedData[plr].division = getDivision(rankedData[plr].elo)
    table.insert(rankedData[plr].history, 1, {result=result, elo=rankedData[plr].elo, division=rankedData[plr].division, date=os.date("%y/%m/%d")})
    if oldDiv ~= rankedData[plr].division then
        triggerClientEvent(plr, "forgex:rankedDivisionUp", plr, rankedData[plr].division)
    end
    triggerClientEvent(plr, "forgex:rankedMatchResult", plr, result, rankedData[plr].elo, rankedData[plr].division)
end
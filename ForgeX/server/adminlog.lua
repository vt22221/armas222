--[[
ForgeX Admin/Logs System
- Registro de eventos importantes do sistema (transações, conquistas, mercado, giftcodes, etc)
- Comandos admin para consulta de logs
- Pronto para integração com Web/Discord/externo
]]

-- Criação da tabela de logs (executar só uma vez)
addEventHandler("onResourceStart", resourceRoot, function()
    dbExec(ForgeXDB.db, "CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY AUTOINCREMENT, time INTEGER, acc TEXT, event TEXT, data TEXT)")
end)

-- Função para registrar log
function logEvent(acc, event, data)
    local now = getRealTime().timestamp
    dbExec(ForgeXDB.db, "INSERT INTO logs (time, acc, event, data) VALUES (?,?,?,?)", now, acc, event, toJSON(data))
end

-- Exemplos de integração:  
-- logEvent(acc, "giftcode_use", {code=code, reward=reward})
-- logEvent(acc, "market_sell", {skin=skin, price=price})
-- logEvent(acc, "skin_evolve", {skin=skin, toLevel=level})

-- Comando admin para consultar logs por evento ou conta
addCommandHandler("logs", function(plr, _, eventOrAcc, lines)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end
    local qh
    lines = tonumber(lines) or 10
    if not eventOrAcc then
        qh = dbQuery(ForgeXDB.db, "SELECT * FROM logs ORDER BY id DESC LIMIT ?", lines)
    elseif string.find(eventOrAcc, "@") then
        qh = dbQuery(ForgeXDB.db, "SELECT * FROM logs WHERE acc=? ORDER BY id DESC LIMIT ?", eventOrAcc, lines)
    else
        qh = dbQuery(ForgeXDB.db, "SELECT * FROM logs WHERE event=? ORDER BY id DESC LIMIT ?", eventOrAcc, lines)
    end
    local result = dbPoll(qh, -1)
    outputChatBox("---- Últimos logs ----", plr, 200,220,255)
    for _,v in ipairs(result or {}) do
        local t = os.date("%d/%m/%y %H:%M", v.time)
        outputChatBox(("#%s [%s] %s | %s | %s"):format(v.id, t, v.acc, v.event, v.data), plr, 180,220,255)
    end
end)

-- Integração opcional: exportar logs para Web/Discord
function exportLogToDiscord(text)
    -- Chame um webhook aqui se quiser integração real
end
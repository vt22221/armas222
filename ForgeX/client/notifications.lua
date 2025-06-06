--[[
ForgeX Notification System (Client-side)
- Exibe notificações visuais para o jogador
- Suporta filas, múltiplas cores, fade in/out, integração multi-idioma
- Integrável em todos os módulos ForgeX
- Eventos reais: "forgex:showNotification"
]]

local notificationQueue = {}
local currentNotification = nil
local notificationStart = 0

local NOTIFY_DURATION = 5    -- segundos
local FADE_TIME = 0.5        -- segundos
local FONT = "default-bold"
local WIDTH = 450
local HEIGHT = 50

function showNotification(msg, r, g, b)
    table.insert(notificationQueue, {msg=msg, r=r or 80, g=g or 255, b=b or 255})
end

addEvent("forgex:showNotification", true)
addEventHandler("forgex:showNotification", root, function(msg, r, g, b)
    showNotification(msg, r, g, b)
end)

function processNotificationQueue()
    if not currentNotification and #notificationQueue > 0 then
        currentNotification = table.remove(notificationQueue, 1)
        notificationStart = getTickCount()
        playSoundFrontEnd(12) -- SFX padrão de notificação
    elseif currentNotification then
        local elapsed = (getTickCount() - notificationStart)/1000
        if elapsed > NOTIFY_DURATION + FADE_TIME then
            currentNotification = nil
        end
    end
end
setTimer(processNotificationQueue, 100, 0)

addEventHandler("onClientRender", root, function()
    if not currentNotification then return end
    local elapsed = (getTickCount() - notificationStart)/1000
    local alpha = 1
    if elapsed < FADE_TIME then
        alpha = elapsed/FADE_TIME
    elseif elapsed > NOTIFY_DURATION then
        alpha = 1 - ((elapsed-NOTIFY_DURATION)/FADE_TIME)
    end
    alpha = math.max(0, math.min(1, alpha))
    local screenW, screenH = guiGetScreenSize()
    local x = (screenW - WIDTH)/2
    local y = screenH * 0.13
    dxDrawRectangle(x, y, WIDTH, HEIGHT, tocolor(30,30,30,200*alpha), false)
    dxDrawRectangle(x, y+HEIGHT-6, WIDTH, 6, tocolor(currentNotification.r, currentNotification.g, currentNotification.b, 180*alpha), false)
    dxDrawText(currentNotification.msg, x+18, y, x+WIDTH-18, y+HEIGHT, tocolor(220,220,220,255*alpha), 1.15, FONT, "center", "center", true, true, false, true)
end)

-- Função utilitária para outros módulos
function triggerNotification(msg, r, g, b)
    triggerEvent("forgex:showNotification", localPlayer, msg, r, g, b)
end

-- Integração com multi-idioma (chame triggerNotification(tr("battlepass_reward", getPlayerLang(), {level=5,prize="AK47 Gold"})))
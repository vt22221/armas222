-- ForgeX Giftcodes System (Server-side)

local validGiftcodes = {
    ["SUPERVIP2025"] = {reward="lootbox", uses=0, max=100}
}
local usedGiftcodes = {} -- [account][code]=true

addEvent("forgex:redeemGiftcode", true)
addEventHandler("forgex:redeemGiftcode", root, function(code)
    local plr = client
    local acc = getPlayerAccount(plr)
    if not acc or isGuestAccount(acc) then return end
    code = tostring(code):upper()
    if not validGiftcodes[code] then
        triggerClientEvent(plr, "forgex:giftcodeFeedback", plr, "invalid", "Giftcode inválido!")
        return
    end
    if not usedGiftcodes[getAccountName(acc)] then usedGiftcodes[getAccountName(acc)] = {} end
    if usedGiftcodes[getAccountName(acc)][code] then
        triggerClientEvent(plr, "forgex:giftcodeFeedback", plr, "already", "Você já usou este código.")
        return
    end
    if validGiftcodes[code].uses >= validGiftcodes[code].max then
        triggerClientEvent(plr, "forgex:giftcodeFeedback", plr, "invalid", "Giftcode esgotado.")
        return
    end
    -- Dar prêmio
    fx_giveItem(plr, validGiftcodes[code].reward, 1)
    usedGiftcodes[getAccountName(acc)][code] = true
    validGiftcodes[code].uses = validGiftcodes[code].uses + 1
    triggerClientEvent(plr, "forgex:giftcodeFeedback", plr, "ok", "Giftcode resgatado!")
end)
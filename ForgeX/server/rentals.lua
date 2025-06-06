-- ForgeX Skin Rental System (Server-side)

local rentalOptions = {
    ["AK-47|Redline"] = {price=500, duration=24, name="Redline (AK)", canRenew=true}
}
local playerRentals = {} -- [player] = { [skin]={expires=timestamp, canRenew=bool, price=int, name=string} }

addEvent("forgex:requestRentals", true)
addEventHandler("forgex:requestRentals", root, function()
    local plr = client
    local rented = playerRentals[plr] or {}
    triggerClientEvent(plr, "forgex:syncRentals", plr, rented, rentalOptions)
end)

addEvent("forgex:rentSkin", true)
addEventHandler("forgex:rentSkin", root, function(skin)
    local plr = client
    local opt = rentalOptions[skin]
    if not opt then return end
    if getPlayerMoney(plr) < opt.price then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Saldo insuficiente.")
        return
    end
    takePlayerMoney(plr, opt.price)
    if not playerRentals[plr] then playerRentals[plr] = {} end
    playerRentals[plr][skin] = {expires=getRealTime().timestamp+opt.duration*3600, canRenew=opt.canRenew, price=opt.price, name=opt.name}
    triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Skin alugada!")
end)

addEvent("forgex:renewRental", true)
addEventHandler("forgex:renewRental", root, function(skin)
    local plr = client
    local rental = playerRentals[plr] and playerRentals[plr][skin]
    local opt = rentalOptions[skin]
    if not rental or not opt or not rental.canRenew then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Não pode renovar.")
        return
    end
    if getPlayerMoney(plr) < opt.price then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Saldo insuficiente.")
        return
    end
    takePlayerMoney(plr, opt.price)
    rental.expires = rental.expires + opt.duration*3600
    triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Renovado!")
end)
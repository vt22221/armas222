-- ForgeX Giftcodes Panel (Client-side)

local isGiftcodeVisible = false
local giftcodeInput = ""
local feedbackMsg = ""

addEvent("forgex:giftcodeFeedback", true)
addEventHandler("forgex:giftcodeFeedback", root, function(status, msg)
    feedbackMsg = msg or ""
end)

bindKey("F1", "down", function()
    isGiftcodeVisible = not isGiftcodeVisible
    giftcodeInput = ""
    feedbackMsg = ""
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isGiftcodeVisible and btn == "escape" and press then
        isGiftcodeVisible = false
        cancelEvent()
    elseif isGiftcodeVisible and press then
        if btn == "backspace" then
            giftcodeInput = giftcodeInput:sub(1,-2)
        elseif #btn == 1 then
            giftcodeInput = giftcodeInput..btn
        elseif btn == "enter" then
            triggerServerEvent("forgex:redeemGiftcode", localPlayer, giftcodeInput)
        end
    end
end)

function drawGiftcodePanel()
    if not isGiftcodeVisible then return end
    local x, y, w, h = 320, 200, 320, 120
    dxDrawRectangle(x, y, w, h, tocolor(25,25,25,220))
    dxDrawText("GIFT CODE", x, y, x+w, y+30, tocolor(255,220,120), 1.2, "default-bold", "center", "top")
    dxDrawText("Digite o código:", x+10, y+40, x+w-10, y+60, tocolor(220,255,220), 1, "default-bold", "left", "top")
    dxDrawRectangle(x+10, y+60, w-20, 28, tocolor(40,40,40,180))
    dxDrawText(giftcodeInput, x+18, y+62, x+w-28, y+82, tocolor(255,255,255), 1, "default", "left", "top")
    dxDrawText(feedbackMsg, x+10, y+92, x+w-10, y+112, tocolor(255,180,180), 0.95, "default")
end
addEventHandler("onClientRender", root, drawGiftcodePanel)
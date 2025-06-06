LotteryTickets = {}

function giveLotteryTicket(acc)
    LotteryTickets[acc] = true
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Você recebeu um ticket para o sorteio semanal!", 80,180,255)
end

function runLotteryDraw()
    local winners = {}
    for acc,_ in pairs(LotteryTickets) do
        if math.random(1,100) <= 10 then -- 10% chance
            table.insert(winners, acc)
            ForgeXDB.addLootbox(acc, "rare", 1)
            triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Você GANHOU o sorteio semanal! Lootbox rara entregue!", 255,215,0)
        end
    end
    LotteryTickets = {}
end
-- Chame runLotteryDraw semanalmente com setTimer ou cron
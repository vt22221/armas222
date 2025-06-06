--[[
ForgeX Multi-language System (Client-side)
- Suporte a múltiplos idiomas para todas as interfaces do jogador
- Carrega tabelas de tradução e permite troca dinâmica de idioma
- Integração simples para qualquer UI: tr("key", lang, {var="x"})
- Pronto para expansão (auto-detect, fallback, customizações)
]]

local supportedLangs = { "pt", "en", "es" }
local translations = {
    pt = {
        inventory_title = "Inventário",
        skin_applied = "Skin %skin% aplicada na %weapon%!",
        lootbox_opened = "Você abriu uma lootbox: %prize%",
        market_buy_fail = "Erro ao comprar: %error%",
        battlepass_claimed = "Recompensa do Battle Pass coletada (Nível %level%)!",
        contract_complete = "Contrato concluído! Ganhou: %item%",
        collection_complete = "Coleção %weapon% completada! Prêmio: %reward%",
        ranked_divup = "Você subiu de divisão!",
        ranked_win = "Vitória (+ELO)! Nova divisão: %division%",
        ranked_lose = "Derrota (-ELO). Nova divisão: %division%",
        achievement_unlocked = "Conquista desbloqueada: %desc%",
        giftcode_ok = "Giftcode resgatado com sucesso!",
        giftcode_invalid = "Código inválido.",
        giftcode_already = "Você já usou este código.",
        rental_feedback = "Aluguel: %msg%",
        adminlog_feedback = "Ação registrada: %msg%",
        -- ... mais traduções ...
    },
    en = {
        inventory_title = "Inventory",
        skin_applied = "Skin %skin% applied on %weapon%!",
        lootbox_opened = "You opened a lootbox: %prize%",
        market_buy_fail = "Purchase error: %error%",
        battlepass_claimed = "Battle Pass reward claimed (Level %level%)!",
        contract_complete = "Contract completed! You won: %item%",
        collection_complete = "Collection %weapon% completed! Reward: %reward%",
        ranked_divup = "You ranked up!",
        ranked_win = "Victory (+ELO)! New division: %division%",
        ranked_lose = "Defeat (-ELO). New division: %division%",
        achievement_unlocked = "Achievement unlocked: %desc%",
        giftcode_ok = "Giftcode redeemed successfully!",
        giftcode_invalid = "Invalid code.",
        giftcode_already = "You already used this code.",
        rental_feedback = "Rental: %msg%",
        adminlog_feedback = "Action registered: %msg%",
        -- ... more translations ...
    },
    es = {
        inventory_title = "Inventario",
        skin_applied = "Skin %skin% aplicada en %weapon%!",
        lootbox_opened = "Abriste una lootbox: %prize%",
        market_buy_fail = "Error al comprar: %error%",
        battlepass_claimed = "¡Recompensa del Pase de Batalla reclamada (Nivel %level%)!",
        contract_complete = "¡Contrato completado! Ganaste: %item%",
        collection_complete = "¡Colección %weapon% completada! Premio: %reward%",
        ranked_divup = "¡Ascendiste de división!",
        ranked_win = "¡Victoria (+ELO)! Nueva división: %division%",
        ranked_lose = "Derrota (-ELO). Nueva división: %division%",
        achievement_unlocked = "Logro desbloqueado: %desc%",
        giftcode_ok = "¡Giftcode canjeado con éxito!",
        giftcode_invalid = "Código inválido.",
        giftcode_already = "Ya usaste este código.",
        rental_feedback = "Alquiler: %msg%",
        adminlog_feedback = "Acción registrada: %msg%",
        -- ... más traducciones ...
    }
}

local currentLang = "pt"

function tr(key, lang, vars)
    lang = lang or currentLang
    local str = translations[lang] and translations[lang][key] or translations["en"][key] or key
    if vars then
        for k,v in pairs(vars) do
            str = str:gsub("%%"..k.."%%", tostring(v))
        end
    end
    return str
end

function setPlayerLang(lang)
    if translations[lang] then
        currentLang = lang
        triggerNotification("Idioma trocado para: "..lang, 80,255,190)
        -- Opcional: salvar em accountData/local
        setElementData(localPlayer, "fx:lang", lang)
    else
        triggerNotification("Idioma não suportado", 255,80,80)
    end
end

function getPlayerLang()
    local lang = getElementData(localPlayer, "fx:lang")
    if translations[lang] then return lang end
    return currentLang
end

-- Comando rápido para trocar idioma
addCommandHandler("idioma", function(_, lang)
    if not lang then
        outputChatBox("Idiomas disponíveis: "..table.concat(supportedLangs, ", "), 255,255,160)
        outputChatBox("/idioma [pt|en|es]", 255,255,160)
        return
    end
    setPlayerLang(lang)
end)

-- Exemplo de uso nas UIs:
-- outputChatBox(tr("inventory_title", getPlayerLang()))
-- triggerNotification(tr("skin_applied", getPlayerLang(), {skin="Gold", weapon="AK"}), 80,255,190)
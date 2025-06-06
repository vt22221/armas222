-- ForgeXClient Main - Carregamento seguro de TXD/DFF, propriedades de armas e inicialização

-- Mapeamento correto de IDs para nomes de armas
local weaponNames = {
    [355] = "ak-47",
    [356] = "m4",
    [358] = "sniper rifle",
    -- Adicione outros conforme o seu resource
}

-- Função para obter o nome da arma a partir do ID
local function getWeaponNameFromID(id)
    return weaponNames[id] or false
end

-- Carregamento seguro dos modelos das armas
local function carregarModelArma(weaponID)
    local weaponName = getWeaponNameFromID(weaponID)
    if not weaponName then
        outputDebugString("Nome da arma não encontrado para ID: "..tostring(weaponID), 2)
        return
    end

    local txdPath = "client/skins/"..weaponName..".txd"
    local dffPath = "client/skins/"..weaponName..".dff"

    local txd = false
    if fileExists(txdPath) then
        txd = engineLoadTXD(txdPath)
        if txd then
            engineImportTXD(txd, weaponID)
        else
            outputDebugString("Falha ao carregar TXD: "..txdPath, 2)
        end
    else
        outputDebugString("TXD não encontrado: "..txdPath, 2)
    end

    local dff = false
    if fileExists(dffPath) then
        dff = engineLoadDFF(dffPath, weaponID)
        if dff then
            engineReplaceModel(dff, weaponID)
        else
            outputDebugString("Falha ao carregar DFF: "..dffPath, 2)
        end
    else
        outputDebugString("DFF não encontrado: "..dffPath, 2)
    end
end

-- Aplicação segura de propriedades nas armas
local function setarPropriedadeArma(weaponID, propriedade, valor)
    local weaponName = getWeaponNameFromID(weaponID)
    if weaponName then
        setWeaponProperty(weaponName, "pro", propriedade, valor)
    else
        outputDebugString("ID da arma inválido para setWeaponProperty: "..tostring(weaponID), 2)
    end
end

-- Inicialização automática ao iniciar o resource
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestPlayerData", resourceRoot)
    triggerServerEvent("forgex:requestInventory", resourceRoot)
    -- Carrega todos os modelos
    for weaponID, _ in pairs(weaponNames) do
        carregarModelArma(weaponID)
    end

    -- Ajusta propriedades (exemplo: pode comentar se não usar)
    setarPropriedadeArma(355, "damage", 36)
    setarPropriedadeArma(356, "damage", 33)
    setarPropriedadeArma(358, "damage", 90)
end)

-- Você pode chamar carregarModelArma(ID) ou setarPropriedadeArma(ID, propriedade, valor) a qualquer momento no seu código
addEvent("forgex:notify", true)
addEventHandler("forgex:notify", root, function(msg)
    outputChatBox("[ForgeX] #FFD700"..msg, 255,255,255,true)
end)
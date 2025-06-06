-- ForgeX UI SVG Loader and General Utilities

-- Cache para SVGs carregados, para não recriar todo frame
local svgCache = {}

-- Função para criar e cachear SVGs a partir de arquivo
function getSVGImage(path, width, height)
    local key = path .. ":" .. width .. "x" .. height
    if svgCache[key] then return svgCache[key] end

    local file = fileOpen(path)
    if not file then
        outputDebugString("SVG não encontrado: " .. tostring(path), 2)
        return nil
    end
    local svgString = fileRead(file, fileGetSize(file))
    fileClose(file)

    -- svgCreate espera (width, height, svgData)
    local svg = svgCreate(width, height, svgString)
    if svg then
        svgCache[key] = svg
    else
        outputDebugString("Erro ao criar SVG: " .. tostring(path), 2)
    end
    return svg
end

-- Função utilitária para limpar SVGs do cache (ex: ao trocar HUD/temas)
function clearSVGCache()
    for _, svg in pairs(svgCache) do
        if isElement(svg) then destroyElement(svg) end
    end
    svgCache = {}
end

-- Exemplo de uso em qualquer painel:
-- local ak47svg = getSVGImage("images/ak47.svg", 64, 32)
-- if ak47svg then
--     dxDrawImage(x, y, 64, 32, ak47svg)
-- end

-- Também pode ser usado para outros SVGs: lootbox.svg, m4a1.svg, etc.

-- Opcional: limpar cache ao sair do resource
addEventHandler("onClientResourceStop", resourceRoot, clearSVGCache)
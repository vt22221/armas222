-- ForgeX: effects.lua (CLIENT) Efeitos visuais e de som

addEvent("forgex:applyWeaponEffect", true)
addEventHandler("forgex:applyWeaponEffect", resourceRoot, function(weapon, skin)
    if skin == "gold" then
        local x, y, z = getPedWeaponMuzzlePosition(localPlayer)
        createEffect("spark", x, y, z)
    elseif skin == "glow" then
        local shader = dxCreateShader("shader.fx")
        engineApplyShaderToWorldTexture(shader, "ak47", 355)
    end
end)
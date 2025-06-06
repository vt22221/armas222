-- ForgeX: config.lua (SHARED) + exports

FORGEX_CONFIG = {
    MODS = {
        scope = {accuracy=0.7},
        silencer = {damage=12},
        flashlight = {on=true},
        stock = {recoil=0.65},
        longbarrel = {range=200},
        fasttrigger = {fireRate=70}
    },
    SKINS = {
        gold = {effect="spark"},
        glow = {effect="glow"}
    },
    EVOLUTION = {
        [0] = {bonus=0},
        [1] = {bonus=0.1},
        [2] = {bonus=0.2}
    },
    XP_EVOLVE = {100, 250, 500, 1000}
}

function getCraftingList()
    return {
        scope = {materials={metal=2, glass=1}, craftTime=3, desc="Mira que aumenta precisão"},
        silencer = {materials={metal=3, rubber=1}, craftTime=4, desc="Silenciador funcional"},
        flashlight = {materials={metal=1, electronics=2}, craftTime=2, desc="Lanterna funcional"},
        stock = {materials={wood=2, metal=1}, craftTime=3, desc="Coronha que reduz recoil"},
        longbarrel = {materials={metal=3}, craftTime=4, desc="Aumenta alcance"},
        fasttrigger = {materials={metal=2, spring=1}, craftTime=3, desc="Aumenta cadência"},
        kitreparo = {materials={metal=1, rubber=1}, craftTime=2, desc="Kit de reparo para armas"}
    }
end

function getModStat(mod)
    return FORGEX_CONFIG.MODS[mod]
end

function getXpToEvolve(evo)
    return FORGEX_CONFIG.XP_EVOLVE[(evo or 0)+1] or 1000
end

addEventHandler("onResourceStart", resourceRoot, function()
    _G["exports"] = _G["exports"] or {}
    exports.forgetx_shared = {
        getCraftingList = getCraftingList,
        getModStat = getModStat,
        getXpToEvolve = getXpToEvolve
    }
end)
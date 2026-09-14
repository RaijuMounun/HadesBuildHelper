StateReader = StateReader or {}

local PrimaryWeapons = {
    SwordWeapon = true,
    SpearWeapon = true,
    ShieldWeapon = true,
    BowWeapon = true,
    FistWeapon = true,
    GunWeapon = true
}

function StateReader.Parse(currentRun, gameState)
    local state = {
        HealthPercent = 1.0,
        GodPool = {},
        GodCount = 0,
        Keepsake = nil,
        MirrorUpgrades = {},
        Aspect = "Base"
    }
    
    if gameState then
        state.Keepsake = gameState.LastAwardTrait
        if gameState.MetaUpgradesSelected then
            for upgrade, _ in pairs(gameState.MetaUpgradesSelected) do
                state.MirrorUpgrades[upgrade] = true
            end
        end
    end
    
    if currentRun and currentRun.Hero then
        local hp = currentRun.Hero.Health or 100
        local maxHp = currentRun.Hero.MaxHealth or 100
        if maxHp > 0 then
            state.HealthPercent = hp / maxHp
        end
        
        if currentRun.Hero.WeaponName then
            state.WeaponName = currentRun.Hero.WeaponName
        elseif type(currentRun.Hero.Weapons) == "table" then
            for weaponName, _ in pairs(currentRun.Hero.Weapons) do
                if PrimaryWeapons[weaponName] then
                    state.WeaponName = weaponName
                    break
                end
            end
            if not state.WeaponName then
                for weaponName, _ in pairs(currentRun.Hero.Weapons) do
                    state.WeaponName = weaponName
                    break
                end
            end
        end

        if currentRun.Hero.Traits then
            for _, trait in ipairs(currentRun.Hero.Traits) do
                local traitName = type(trait) == "table" and trait.Name or trait
                if type(traitName) == "string" then
                    if traitName == "SwordCritTrait" then state.Aspect = "Nemesis"
                    elseif traitName == "SwordLifestealTrait" then state.Aspect = "Arthur"
                    elseif traitName == "GunGrenadeTrait" then state.Aspect = "Eris"
                    elseif traitName == "BowSpecialBarrageTrait" then state.Aspect = "Chiron"
                    elseif traitName == "ShieldLoadAmmoTrait" then state.Aspect = "Beowulf"
                    elseif traitName == "SpearTeleportTrait" then state.Aspect = "Achilles"
                    end
                end
            end
        end
    end
    
    if currentRun and currentRun.LootTypeHistory then
        for _, god in ipairs(currentRun.LootTypeHistory) do
            if not state.GodPool[god] then
                state.GodPool[god] = true
                state.GodCount = state.GodCount + 1
            end
        end
    end
    
    return state
end

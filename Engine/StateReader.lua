-- StateReader.lua
StateReader = StateReader or {}

local PrimaryWeapons = {
    SwordWeapon = true,
    SpearWeapon = true,
    ShieldWeapon = true,
    BowWeapon = true,
    FistWeapon = true,
    GunWeapon = true
}

function StateReader.Parse(currentRun)
    local state = {
        HealthPercent = 1.0,
        GodPool = {},
        GodCount = 0
    }
    
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

-- StateReader.lua
local StateReader = {}

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

return StateReader

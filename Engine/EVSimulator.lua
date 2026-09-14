EVSimulator = EVSimulator or {}

local CoreGods = {
    Zeus = true, Poseidon = true, Athena = true, Aphrodite = true,
    Artemis = true, Ares = true, Dionysus = true, Demeter = true
}

function EVSimulator.CalculateViability(weapon_blueprints, parsedState)
    local results = {}
    
    local weapon_bps = weapon_blueprints[parsedState.WeaponName]
    if not weapon_bps then return results end
    
    local builds_to_eval = {}
    if parsedState.Aspect and weapon_bps[parsedState.Aspect] then
        for _, bp in ipairs(weapon_bps[parsedState.Aspect]) do
            table.insert(builds_to_eval, bp)
        end
    end
    if parsedState.Aspect ~= "Base" and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do
            table.insert(builds_to_eval, bp)
        end
    end
    if parsedState.Aspect == nil and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do
            table.insert(builds_to_eval, bp)
        end
    end

    local active_god_count = parsedState.GodCount or 0
    local active_gods = parsedState.GodPool or {}
    local keepsake = parsedState.Keepsake

    for _, bp in ipairs(builds_to_eval) do
        local viability = 1.0
        
        local required_new_gods = 0
        local god_match_score = 0
        if bp.RequiredGods then
            for _, bgod in ipairs(bp.RequiredGods) do
                if active_gods[bgod] then
                    god_match_score = god_match_score + 1
                else
                    required_new_gods = required_new_gods + 1
                end
                
                -- Keepsake bump
                if keepsake and string.find(keepsake, bgod) then
                    viability = viability + 0.5
                end
            end
            
            if active_god_count + required_new_gods > 4 and required_new_gods > 0 then
                viability = viability * 0.1
            end
            
            if #bp.RequiredGods > 0 then
                viability = viability * (1.0 + (god_match_score / #bp.RequiredGods))
            end
        end
        
        table.insert(results, { Blueprint = bp, Viability = viability })
    end
    
    return results
end

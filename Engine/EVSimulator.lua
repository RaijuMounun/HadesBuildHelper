local EVSimulator = {}

function EVSimulator.PruneBlueprints(blueprints, active_gods)
    local active_count = 0
    local god_set = {}
    
    if active_gods then
        for _, god in ipairs(active_gods) do
            if not god_set[god] then
                god_set[god] = true
                active_count = active_count + 1
            end
        end
    end

    local valid_blueprints = {}
    for _, bp in ipairs(blueprints) do
        local required_new_gods = 0
        if bp.Gods then
            for _, bgod in ipairs(bp.Gods) do
                if not god_set[bgod] then
                    required_new_gods = required_new_gods + 1
                end
            end
        end
        
        -- If we have fewer than 4 gods, we can add new ones up to the limit of 4.
        -- If we already have 4 or more gods, we can only pursue blueprints that don't add new gods.
        if active_count + required_new_gods <= 4 or required_new_gods == 0 then
            table.insert(valid_blueprints, bp)
        end
    end
    
    return valid_blueprints
end

return EVSimulator

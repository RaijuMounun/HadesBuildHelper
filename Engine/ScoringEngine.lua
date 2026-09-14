ScoringEngine = ScoringEngine or {}

local function curve_polynomial(x, exponent)
    return x ^ exponent
end

function ScoringEngine.calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    -- Panic State: inverse polynomial curve
    local panic_factor = curve_polynomial(1.0 - health_percent, 2.0)
    -- Panic modifier scales from 1x (at 100% HP) up to 5x (at 0% HP)
    local state_mod = 1.0 + (panic_factor * 4.0)
    
    local pool_mod = pool_penalty_active and 0.01 or 1.00

    local final = base_score * rarity_mod * state_mod * pool_mod
    -- Clamp between 0.0 and 1.0
    return math.min(1.0, math.max(0.0, final))
end

function ScoringEngine.evaluate_boon(boon_name, blueprints)
    local max_score = 0.0
    for _, blueprint in ipairs(blueprints) do
        for _, core_trait in ipairs(blueprint.CoreTraits) do
            if core_trait == boon_name then
                max_score = math.max(max_score, 1.0)
            end
        end
    end
    -- Return a minimal score if it's not a core trait in any blueprint
    if max_score > 0 then
        return max_score
    else
        return 0.1
    end
end

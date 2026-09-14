ScoringEngine = ScoringEngine or {}

local function curve_polynomial(x, exponent)
    return x ^ exponent
end

function ScoringEngine.calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    local panic_factor = curve_polynomial(1.0 - health_percent, 2.0)
    local state_mod = 1.0 + (panic_factor * 4.0)
    local pool_mod = pool_penalty_active and 0.01 or 1.00

    local final = base_score * rarity_mod * state_mod * pool_mod
    return math.min(1.0, math.max(0.0, final))
end

function ScoringEngine.evaluate_boon(boon_name, viable_builds)
    local total_score = 0.0
    for _, vb in ipairs(viable_builds) do
        if vb.Blueprint.Components and vb.Blueprint.Components[boon_name] then
            total_score = total_score + (vb.Blueprint.Components[boon_name] * vb.Viability)
        end
    end
    
    if total_score > 0 then
        -- Normalize the final score to a [0.0, 1.0] range using a simple divisor limit
        return math.min(1.0, total_score / 2.0)
    else
        return 0.1
    end
end

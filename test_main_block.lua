
WeaponBlueprints = { SwordWeapon = { Nemesis = { { Name = "Zeus Nemesis", Components = { ZeusWeaponTrait = 1.0 }, RequiredGods = { "Zeus" } } } } }

EVSimulator = {}
function EVSimulator.CalculateViability(weapon_blueprints, parsedState)
    local results = {}
    local weapon_bps = weapon_blueprints[parsedState.WeaponName]
    if not weapon_bps then return results end
    local builds_to_eval = {}
    if parsedState.Aspect and weapon_bps[parsedState.Aspect] then
        for _, bp in ipairs(weapon_bps[parsedState.Aspect]) do table.insert(builds_to_eval, bp) end
    end
    if parsedState.Aspect ~= "Base" and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do table.insert(builds_to_eval, bp) end
    end
    if parsedState.Aspect == nil and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do table.insert(builds_to_eval, bp) end
    end
    return results
end

ScoringEngine = {}
local function curve_polynomial(x, exponent) return x ^ exponent end
function ScoringEngine.calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    return base_score * 1.0
end
function ScoringEngine.evaluate_boon(boon_name, viable_builds)
    local total_score = 0.0
    for _, vb in ipairs(viable_builds) do
        if vb.Blueprint.Components and vb.Blueprint.Components[boon_name] then
            total_score = total_score + (vb.Blueprint.Components[boon_name] * vb.Viability)
        end
    end
    if total_score > 0 then return total_score / 2.0 else return 0.1 end
end

local parsedState = { HealthPercent = 1.0, GodPool = {}, GodCount = 0, Aspect = "Base", WeaponName = "SwordWeapon" }
local viable_builds = {}
local success, err = pcall(function()
    viable_builds = EVSimulator.CalculateViability(WeaponBlueprints, parsedState)
end)
print("CalculateViability Success:", success, "Err:", err)

local success2, err2 = pcall(function()
    local base_score = ScoringEngine.evaluate_boon("ZeusWeaponTrait", viable_builds)
    local score = ScoringEngine.calculate_score(base_score, 1.0, 1.0, false)
    local final_score_int = math.floor(score * 100 + 0.5)
    print("UI Score:", final_score_int)
end)
print("Evaluate Success:", success2, "Err:", err2)


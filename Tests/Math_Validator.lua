-- AAA Standard: Standalone Math Validator for Utility AI (V2 - Response Curves)
-- Usage: lua Math_Validator.lua

-- Utility Engine Scoring Mock using Response Curves
local function curve_polynomial(x, exponent)
    return x ^ exponent
end

local function calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    -- Panic State: inverse polynomial curve
    local panic_factor = curve_polynomial(1.0 - health_percent, 2.0)
    -- Panic modifier scales from 1x (at 100% HP) up to 5x (at 0% HP)
    local state_mod = 1.0 + (panic_factor * 4.0)
    
    local pool_mod = pool_penalty_active and 0.01 or 1.00

    local final = base_score * rarity_mod * state_mod * pool_mod
    -- Clamp between 0.0 and 1.0
    return math.min(1.0, math.max(0.0, final))
end

-- Math Test Vectors (Syncs with 10_Math_Test_Vectors.md)
local TestVectors = {
    {
        name = "TV1: Core Blueprint Boon (Healthy)",
        inputs = { base = 0.80, rarity = 1.00, hp = 1.00, pool = false },
        expected = 0.80
    },
    {
        name = "TV2: Panic State Override (Food at 10% HP)",
        inputs = { base = 0.30, rarity = 1.00, hp = 0.10, pool = false },
        expected = 1.00
    },
    {
        name = "TV3: 4-God Pool Penalty on New God",
        inputs = { base = 0.80, rarity = 1.50, hp = 1.00, pool = true },
        expected = 0.012
    },
    {
        name = "TV4: Epic Rarity Modifier (at 80% HP)",
        inputs = { base = 0.50, rarity = 1.50, hp = 0.80, pool = false },
        expected = 0.87 -- 0.50 * 1.50 * (1.0 + 0.04*4.0) = 0.75 * 1.16 = 0.87
    }
}

local passed = 0
local failed = 0
local EPSILON = 0.0001

print("========================================")
print("Starting AAA Math Validator Test Suite...")
print("========================================")

for i, test in ipairs(TestVectors) do
    local result = calculate_score(test.inputs.base, test.inputs.rarity, test.inputs.hp, test.inputs.pool)
    local diff = math.abs(result - test.expected)
    
    if diff <= EPSILON then
        print(string.format("[PASS] %s", test.name))
        passed = passed + 1
    else
        print(string.format("[FAIL] %s | Expected: %.3f, Got: %.3f", test.name, test.expected, result))
        failed = failed + 1
    end
end

print("========================================")
print(string.format("RESULTS: %d Passed, %d Failed", passed, failed))
print("========================================")

if failed > 0 then
    os.exit(1)
else
    os.exit(0)
end

-- AAA Standard: Standalone Math Validator for Utility AI (V2 - Response Curves)
-- Usage: lua Math_Validator.lua

local MockGameData = require("Tests.MockGameData")
local GameDataParser = require("Data.GameDataParser")
local StateReader = require("Engine.StateReader")
local ScoringEngine = require("Engine.ScoringEngine")
local EVSimulator = require("Engine.EVSimulator")
local Blueprints = require("Data.Blueprints")


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
    },
    {
        name = "TV5: GameDataParser - Trait Name Extracted",
        inputs = { type = "parser", mockKey = "ZeusWeaponBoon" },
        expected = "ZeusWeaponBoon"
    },
    {
        name = "TV6: StateReader - Health Percent Calculation",
        inputs = { type = "statereader" },
        expected = 0.25
    },
    {
        name = "TV7: EVSimulator - PruneBlueprints checks 4-God limit",
        inputs = { type = "pruning" },
        expected = 2
    },
    {
        name = "TV8: ScoringEngine - Blueprint Boon Evaluation",
        inputs = { type = "blueprint_eval", boon = "ZeusWeaponBoon" },
        expected = 1.0
    }
}

local passed = 0
local failed = 0
local EPSILON = 0.0001

print("========================================")
print("Starting AAA Math Validator Test Suite...")
print("========================================")

for i, test in ipairs(TestVectors) do
    local result
    local passed_test = false
    
    if test.inputs.type == "parser" then
        local parsed = GameDataParser.ParseTraits(MockGameData.TraitData)
        result = parsed[test.inputs.mockKey].Name
        passed_test = (result == test.expected)
    elseif test.inputs.type == "statereader" then
        local state = StateReader.Parse(MockGameData.CurrentRun)
        result = state.HealthPercent
        passed_test = (math.abs(result - test.expected) <= EPSILON)
    elseif test.inputs.type == "pruning" then
        local valid = EVSimulator.PruneBlueprints(Blueprints, MockGameData.CurrentRun.LootTypeHistory)
        result = #valid
        passed_test = (result == test.expected)
    elseif test.inputs.type == "blueprint_eval" then
        result = ScoringEngine.evaluate_boon(test.inputs.boon, Blueprints)
        passed_test = (math.abs(result - test.expected) <= EPSILON)
    else
        result = ScoringEngine.calculate_score(test.inputs.base, test.inputs.rarity, test.inputs.hp, test.inputs.pool)
        passed_test = (math.abs(result - test.expected) <= EPSILON)
    end
    
    if passed_test then
        print(string.format("[PASS] %s", test.name))
        passed = passed + 1
    else
        print(string.format("[FAIL] %s | Expected: %s, Got: %s", test.name, tostring(test.expected), tostring(result)))
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

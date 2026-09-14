-- AAA Standard: Standalone Math Validator for Utility AI (V2 - Response Curves)
-- Usage: lua Math_Validator.lua

local MockGameData = require("Tests.MockGameData")
_G.GameState = {
    LastAwardTrait = "ZeusKeepsake",
    MetaUpgradesSelected = { StygianSoulTrait = true }
}

require("Data.GameDataParser")
require("Engine.StateReader")
require("Engine.ScoringEngine")
require("Engine.EVSimulator")
require("Data.Blueprints")

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
        expected = 0.87
    },
    {
        name = "TV5: GameDataParser - Trait Name Extracted",
        inputs = { type = "parser", mockKey = "ZeusWeaponBoon" },
        expected = "ZeusWeaponBoon"
    },
    {
        name = "TV6: StateReader - Health Percent and GameState parsing",
        inputs = { type = "statereader" },
        expected = { hp = 0.25, keepsake = "ZeusKeepsake", mirror = true, aspect = "Nemesis" }
    },
    {
        name = "TV7: EVSimulator - Viability calculation and filtering",
        inputs = { type = "viability" },
        expected = true 
    },
    {
        name = "TV8: ScoringEngine - Blueprint Boon Evaluation (Pivot)",
        inputs = { type = "blueprint_eval", boon = "ImpactBoltTrait" },
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
        MockGameData.CurrentRun.Hero.Traits = { { Name = "SwordCritTrait" } }
        MockGameData.CurrentRun.Hero.WeaponName = "SwordWeapon"
        local state = StateReader.Parse(MockGameData.CurrentRun, _G.GameState)
        passed_test = (math.abs(state.HealthPercent - test.expected.hp) <= EPSILON) 
                  and (state.Keepsake == test.expected.keepsake)
                  and (state.MirrorUpgrades["StygianSoulTrait"] == test.expected.mirror)
                  and (state.Aspect == test.expected.aspect)
        result = state.Aspect
    elseif test.inputs.type == "viability" then
        MockGameData.CurrentRun.Hero.Traits = { { Name = "SwordCritTrait" } }
        MockGameData.CurrentRun.Hero.WeaponName = "SwordWeapon"
        local state = StateReader.Parse(MockGameData.CurrentRun, _G.GameState)
        local viable = EVSimulator.CalculateViability(WeaponBlueprints, state)
        local found = false
        for _, v in ipairs(viable) do
            if v.Blueprint.Name == "Zeus Nemesis" and v.Viability > 1.0 then
                found = true
            end
        end
        passed_test = found
        result = found
    elseif test.inputs.type == "blueprint_eval" then
        MockGameData.CurrentRun.Hero.Traits = { { Name = "SwordCritTrait" } }
        MockGameData.CurrentRun.Hero.WeaponName = "SwordWeapon"
        local state = StateReader.Parse(MockGameData.CurrentRun, _G.GameState)
        local viable = EVSimulator.CalculateViability(WeaponBlueprints, state)
        result = ScoringEngine.evaluate_boon(test.inputs.boon, viable)
        passed_test = (result > 0.1)
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

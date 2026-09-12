local MockColor = {
    Red = {255, 0, 0, 255},
    Gold = {255, 215, 0, 255},
    White = {255, 255, 255, 255},
    DarkGray = {169, 169, 169, 255}
}
-- Mocking Hades globals
_G.Color = MockColor

_G.thread = function(fn) fn() end
_G.wait = function(time) end
_G.CreateTextBox = function(args) end
_G.ModifyTextBox = function(args) end
_G.DebugPrint = function(args) print(args.Text) end

-- Mocking ModUtil
_G.ModUtil = { Path = { Wrap = function() end } }

require("UI.UIRenderer")

local TestVectors = {
    {
        name = "FormatScore 100%",
        func = function() return HadesHelper.UI.FormatScore(1.0) == "[ 100% ]" end
    },
    {
        name = "FormatScore 85%",
        func = function() return HadesHelper.UI.FormatScore(0.85) == "[ 85% ]" end
    },
    {
        name = "FormatScore 5%",
        func = function() return HadesHelper.UI.FormatScore(0.05) == "[ 5% ]" end
    },
    {
        name = "Color Destructive (Red)",
        func = function() return HadesHelper.UI.GetColorForScore(1.0, true) == Color.Red end
    },
    {
        name = "Color Gold (>= 80%)",
        func = function() return HadesHelper.UI.GetColorForScore(0.80, false) == Color.Gold end
    },
    {
        name = "Color White (>= 50% and < 80%)",
        func = function() return HadesHelper.UI.GetColorForScore(0.79, false) == Color.White end
    },
    {
        name = "Color DarkGray (< 50%)",
        func = function() return HadesHelper.UI.GetColorForScore(0.49, false) == Color.DarkGray end
    }
}

local passed = 0
local failed = 0

print("========================================")
print("Starting AAA UI Validator Test Suite...")
print("========================================")

for i, test in ipairs(TestVectors) do
    local success, result = pcall(test.func)
    if success and result then
        print(string.format("[PASS] %s", test.name))
        passed = passed + 1
    else
        print(string.format("[FAIL] %s | Error: %s", test.name, tostring(result)))
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

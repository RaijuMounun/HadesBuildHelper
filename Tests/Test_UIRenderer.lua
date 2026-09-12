local MockColor = {
    Red = {255, 0, 0, 255},
    Gold = {255, 215, 0, 255},
    White = {255, 255, 255, 255},
    DarkGray = {169, 169, 169, 255}
}
-- Mocking Hades globals
_G.Color = MockColor

local lastTextBoxArgs = nil
_G.thread = function(fn) fn() end
_G.wait = function(time) end
_G.CreateTextBox = function(args) lastTextBoxArgs = args end
_G.ModifyTextBox = function(args) end
_G.DebugPrint = function(args) print(args.Text) end

-- Mocking ModUtil
_G.ModUtil = { Path = { Wrap = function(path, fn) end } }

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
        name = "FormatScore 79.9% floors correctly",
        func = function() return HadesHelper.UI.FormatScore(0.799) == "[ 80% ]" end
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
    },
    {
        name = "RenderComponentScore calls CreateTextBox with right args",
        func = function()
            lastTextBoxArgs = nil
            local mockComponent = { Id = 12345 }
            HadesHelper.UI.RenderComponentScore(mockComponent, 0.85, false)
            return lastTextBoxArgs ~= nil 
               and lastTextBoxArgs.Id == 12345 
               and lastTextBoxArgs.Text == "[ 85% ]"
               and lastTextBoxArgs.Color == Color.Gold
        end
    },
    {
        name = "RenderRerollRecommendation shows if EV is low",
        func = function()
            lastTextBoxArgs = nil
            local diceComponent = { Id = 999 }
            HadesHelper.UI.RenderRerollRecommendation(diceComponent, 0.90, 0.70)
            if lastTextBoxArgs == nil then error("lastTextBoxArgs is nil") end
            if lastTextBoxArgs.Id ~= 999 then error("Id is " .. tostring(lastTextBoxArgs.Id)) end
            if lastTextBoxArgs.Text ~= "[ REROLL TAVSİYESİ: 90% ]" then error("Text is '" .. tostring(lastTextBoxArgs.Text) .. "'") end
            return true
        end
    },
    {
        name = "RenderRerollRecommendation does not show if EV is high",
        func = function()
            lastTextBoxArgs = nil
            local diceComponent = { Id = 999 }
            HadesHelper.UI.RenderRerollRecommendation(diceComponent, 0.90, 0.80) -- 0.80 > (0.90 - 0.15) -> 0.75
            return lastTextBoxArgs == nil
        end
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

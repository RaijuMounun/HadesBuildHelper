HadesHelper = HadesHelper or {}
HadesHelper.UI = HadesHelper.UI or {}

-- Mathematical Verification of UI Logic
function HadesHelper.UI.GetColorForScore(score, isDestructive)
    if isDestructive then
        return Color.Red
    end
    if score >= 0.80 then
        return Color.Gold
    elseif score >= 0.50 then
        return Color.White
    else
        return Color.DarkGray
    end
end

function HadesHelper.UI.FormatScore(score)
    -- Using math.floor(score * 100 + 0.5) to avoid floating point precision issues 
    -- such as 0.79 * 100 evaluating to 78.99999 and rounding down to 78
    return "[ " .. math.floor(score * 100 + 0.5) .. "% ]"
end

function HadesHelper.UI.RenderComponentScore(component, score, isDestructive, offsetX, offsetY)
    if component == nil or component.Id == nil then return end
    CreateTextBox({
        Id = component.Id,
        Text = HadesHelper.UI.FormatScore(score),
        Color = HadesHelper.UI.GetColorForScore(score, isDestructive),
        OffsetX = offsetX or 350,
        OffsetY = offsetY or -35,
        FontSize = 24,
        Justification = "Right",
        ShadowColor = {0,0,0,1},
        ShadowOffset = {0, 2},
        ShadowBlur = 0,
        OutlineColor = {0,0,0,1},
        OutlineThickness = 2,
    })
end

function HadesHelper.UI.RenderRerollRecommendation(diceComponent, expectedValue, currentHighestEV)
    if diceComponent == nil or diceComponent.Id == nil then return end
    -- Recommend reroll if highest EV on screen is significantly lower than pool EV
    if currentHighestEV < (expectedValue - 0.15) then
        CreateTextBox({
            Id = diceComponent.Id,
            Text = "[ REROLL TAVSİYESİ: " .. math.floor(expectedValue * 100 + 0.5) .. "% ]",
            Color = Color.Gold,
            OffsetX = 0,
            OffsetY = -60,
            FontSize = 24,
            Justification = "Center",
            ShadowColor = {0,0,0,1},
            ShadowOffset = {0, 2},
            OutlineColor = {0,0,0,1},
            OutlineThickness = 2,
        })
    end
end

-- =========================================
-- ModUtil Hooks
-- =========================================

local function WrapWithAsyncUIRender(hookName, renderLogic)
    ModUtil.Path.Wrap(hookName, function(baseFunc, ...)
        local rv = baseFunc(...)
        local args = {...}
        
        -- Run AI logic in a non-blocking thread, waiting exactly 0.2s for UI fade-in
        thread(function()
            wait(0.2)
            local status, err = pcall(function()
                if renderLogic then
                    renderLogic(rv, args)
                end
            end)
            if not status then
                DebugPrint({Text = "HadesHelper Error in " .. hookName .. " hook: " .. tostring(err)})
            end
        end)
        
        return rv
    end)
end

-- Hook 1: ShowUpgradeScreen (God Boons)
WrapWithAsyncUIRender("ShowUpgradeScreen", function(rv, args)
    -- Skeleton logic to parse boon components and render scores
    -- Uses typical Hades modding structure (e.g. screen components)
    local screen = args[1] or rv
    if screen and screen.Components then
        for key, comp in pairs(screen.Components) do
            if string.match(key, "UpgradeChoice") or string.match(key, "PurchaseButton") then
                -- TODO: Fetch real score from core logic when integrated
                -- HadesHelper.UI.RenderComponentScore(comp, 0.85, false)
            end
        end
    end
end)

-- Hook 2: CreateBoonLootButtons
WrapWithAsyncUIRender("CreateBoonLootButtons", function(rv, args)
    -- Implementation details for extracting components pending Core Logic
end)

-- Hook 3: CreatePomLootButtons (Poms)
WrapWithAsyncUIRender("CreatePomLootButtons", function(rv, args)
    -- Implementation details pending Core Logic
end)

-- Hook 4: ShowWeaponUpgradeScreen (Daedalus Hammers)
WrapWithAsyncUIRender("ShowWeaponUpgradeScreen", function(rv, args)
    -- Implementation details pending Core Logic
end)

-- Hook 5: HandleUpgradeChoiceReroll (Fated Persuasion/Authority)
WrapWithAsyncUIRender("HandleUpgradeChoiceReroll", function(rv, args)
    -- Reroll triggers new choices, need to wait and render scores again
end)

-- Hook 6: CreateDoorButtons & HandleRoomReward (Door/Room Evaluation)
WrapWithAsyncUIRender("CreateDoorButtons", function(rv, args)
end)

WrapWithAsyncUIRender("HandleRoomReward", function(rv, args)
end)

-- Hook 7: CreateStoreButtons (Charon Shops and Wells)
WrapWithAsyncUIRender("CreateStoreButtons", function(rv, args)
end)

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
    return "[ " .. math.floor(score * 100) .. "% ]"
end

function HadesHelper.UI.RenderComponentScoreAsync(component, score, isDestructive, offsetX, offsetY)
    thread(function()
        wait(0.2) -- respect the base game's 0.15s UI fade-in
        local status, err = pcall(function()
            if component ~= nil and component.Id ~= nil then
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
        end)
        if not status then
            DebugPrint({Text = "HadesHelper Error rendering UI: " .. tostring(err)})
        end
    end)
end

function HadesHelper.UI.RenderRerollRecommendationAsync(diceComponent, expectedValue, currentHighestEV)
    thread(function()
        wait(0.2)
        local status, err = pcall(function()
            if diceComponent ~= nil and diceComponent.Id ~= nil then
                -- Recommend reroll if highest EV on screen is significantly lower than pool EV
                if currentHighestEV < (expectedValue - 0.15) then
                    CreateTextBox({
                        Id = diceComponent.Id,
                        Text = "[ REROLL TAVSİYESİ: " .. math.floor(expectedValue * 100) .. "% ]",
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
        end)
        if not status then
            DebugPrint({Text = "HadesHelper Error rendering Reroll: " .. tostring(err)})
        end
    end)
end

-- =========================================
-- ModUtil Hooks
-- =========================================

ModUtil.Path.Wrap("ShowUpgradeScreen", function(baseFunc, ...)
    local rv = baseFunc(...)
    local status, err = pcall(function()
        -- Logic to iterate boon buttons and call RenderComponentScoreAsync
    end)
    if not status then
        DebugPrint({Text = "HadesHelper Error in ShowUpgradeScreen hook: " .. tostring(err)})
    end
    return rv
end)

ModUtil.Path.Wrap("CreateBoonLootButtons", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("CreatePomLootButtons", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("ShowWeaponUpgradeScreen", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("HandleUpgradeChoiceReroll", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("CreateDoorButtons", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("HandleRoomReward", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

ModUtil.Path.Wrap("CreateStoreButtons", function(baseFunc, ...)
    local rv = baseFunc(...)
    return rv
end)

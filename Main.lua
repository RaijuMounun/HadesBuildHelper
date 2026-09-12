-- Main Lua entry point for HadesBuildHelper
ModUtil.Mod.Register("HadesHelper")

-- ============================================================
-- [DEBUG TEST] - Remove after in-game UI verification
-- Shows "HadesHelper ACTIVE" text when boon screen opens
-- Hook: CreateBoonLootButtons (real function from UpgradeChoice.lua)
-- Anchor: ScreenAnchors.ChoiceScreen.Components.ShopBackground
-- ============================================================
ModUtil.Path.Wrap("CreateBoonLootButtons", function(baseFunc, ...)
    local rv = baseFunc(...)
    thread(function()
        wait(0.5)
        local ok, err = pcall(function()
            local screen = ScreenAnchors.ChoiceScreen
            if screen and screen.Components and screen.Components.ShopBackground then
                CreateTextBox({
                    Id = screen.Components.ShopBackground.Id,
                    Text = "HadesHelper ACTIVE",
                    Color = { 1, 0.84, 0, 1 },
                    OffsetX = 0,
                    OffsetY = -260,
                    FontSize = 20,
                    Justification = "Center",
                    ShadowColor = { 0, 0, 0, 1 },
                    ShadowOffset = { 0, 2 },
                    OutlineThickness = 2,
                })
            end
        end)
        if not ok then
            print("[HadesHelper] UI Error: " .. tostring(err))
        end
    end)
    return rv
end)

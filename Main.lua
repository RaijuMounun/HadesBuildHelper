-- Main Lua entry point for HadesBuildHelper
ModUtil.Mod.Register("HadesHelper")

-- ============================================================
-- [DEBUG TEST] - Remove after in-game UI verification
-- Hook: OpenUpgradeChoiceMenu (confirmed from UpgradeChoice.lua line 2)
-- Anchor: ScreenAnchors.ChoiceScreen.Components.ShopBackground.Id
-- ============================================================
ModUtil.Path.Wrap("OpenUpgradeChoiceMenu", function(baseFunc, ...)
    local rv = baseFunc(...)
    thread(function()
        wait(0.5)
        local ok, err = pcall(function()
            local screen = ScreenAnchors.ChoiceScreen
            if screen and screen.Components and screen.Components.ShopBackground then
                CreateTextBox({
                    Id = screen.Components.ShopBackground.Id,
                    Text = "[ HadesHelper v1.0 ]",
                    Color = { 0, 1, 0.5, 1 }, -- Bright cyan-green, easy to spot
                    OffsetX = 0,
                    OffsetY = 220,             -- Below the boon list, not overlapping
                    FontSize = 22,
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

-- Main Lua entry point for HadesBuildHelper
ModUtil.Mod.Register("HadesHelper")

-- ============================================================
-- [DEBUG TEST] - Remove after in-game UI verification
-- Shows "HadesHelper ✓" in top-left corner when boon screen opens
-- ============================================================
ModUtil.Path.Wrap("ShowUpgradeScreen", function(baseFunc, ...)
    local rv = baseFunc(...)
    thread(function()
        wait(0.3)
        local screenAnchor = ScreenAnchors and ScreenAnchors["UpgradeScreen"]
        if screenAnchor then
            CreateTextBox({
                Id = screenAnchor,
                Text = "HadesHelper ACTIVE ✓",
                Color = { 1, 0.84, 0, 1 }, -- Gold
                OffsetX = -800,
                OffsetY = 480,
                FontSize = 22,
                Justification = "Left",
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 2 },
                OutlineThickness = 2,
            })
        end
    end)
    return rv
end)

-- Main Lua entry point for HadesBuildHelper
ModUtil.Mod.Register("HadesHelper")

-- ============================================================
-- [DEBUG TEST] - Remove after verification
-- Creates our OWN screen component as anchor (no ScreenAnchors dependency)
-- ============================================================
ModUtil.Path.Wrap("OpenUpgradeChoiceMenu", function(baseFunc, ...)
    local rv = baseFunc(...)
    thread(function()
        wait(0.8)
        -- Create our own anchor instead of relying on ScreenAnchors
        local anchor = CreateScreenComponent({
            Name = "rectangle01",
            Group = "Combat_Menu_Additive",
            X = ScreenCenterX,
            Y = ScreenCenterY + 280,
        })
        if anchor then
            CreateTextBox({
                Id = anchor.Id,
                Text = "[ HadesHelper v1.0 ACTIVE ]",
                Color = { 0.2, 1, 0.2, 1 },   -- Bright lime green
                OffsetX = 0,
                OffsetY = 0,
                FontSize = 26,
                Justification = "Center",
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 3 },
                OutlineThickness = 3,
            })
        end
    end)
    return rv
end)

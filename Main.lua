-- Main Lua entry point for HadesBuildHelper
ModUtil.Mod.Register("HadesHelper")

-- ============================================================
-- [DEBUG TEST] Pure Lua monkey-patch - no ModUtil dependency
-- If this works, we know the function is being called correctly
-- ============================================================
local _OriginalOpenUpgradeChoiceMenu = OpenUpgradeChoiceMenu
OpenUpgradeChoiceMenu = function(...)
    local rv = _OriginalOpenUpgradeChoiceMenu(...)
    thread(function()
        wait(0.8)
        local anchor = CreateScreenComponent({
            Name = "rectangle01",
            Group = "Combat_Menu_Additive",
            X = ScreenCenterX,
            Y = ScreenCenterY + 300,
        })
        if anchor and anchor.Id then
            CreateTextBox({
                Id = anchor.Id,
                Text = "[ HadesHelper ACTIVE ]",
                Color = { 0.2, 1, 0.2, 1 },
                OffsetX = 0,
                OffsetY = 0,
                FontSize = 28,
                Justification = "Center",
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 3 },
                OutlineThickness = 3,
            })
        end
    end)
    return rv
end

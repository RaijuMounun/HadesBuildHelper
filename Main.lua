-- HadesBuildHelper - Minimal diagnostic test
ModUtil.Mod.Register("HadesHelper")
HadesHelper = HadesHelper or {}

-- OnAnyLoad fires when a room loads - by that point ALL game scripts are defined.
-- We apply our monkey-patch exactly once here, so it's never overwritten.
OnAnyLoad{ function( triggerArgs )
    if HadesHelper.Initialized then return end
    HadesHelper.Initialized = true

    local origFunc = OpenUpgradeChoiceMenu
    OpenUpgradeChoiceMenu = function( ... )
        local rv = origFunc( ... )
        thread( function()
            wait( 0.5 )
            if CurrentRun and CurrentRun.Hero then
                CreateTextBox({
                    Id = CurrentRun.Hero.ObjectId,
                    Text = "HH Active",
                    Color = { 1, 1, 0, 1 },
                    OffsetX = 0,
                    OffsetY = -130,
                    FontSize = 28,
                    Justification = "Center",
                    ShadowColor = { 0, 0, 0, 1 },
                    ShadowOffset = { 0, 2 },
                    OutlineThickness = 3,
                })
            end
        end )
        return rv
    end
end }

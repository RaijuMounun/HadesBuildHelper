-- HadesBuildHelper - Main Entry
ModUtil.Mod.Register("HadesHelper")
HadesHelper = HadesHelper or {}

-- We use OnAnyLoad to ensure our hooks run AFTER all game scripts are loaded
OnAnyLoad{ function( triggerArgs )
    if HadesHelper.Initialized then return end
    HadesHelper.Initialized = true

    -- 1. Hook opening the boon screen
    local origOpen = OpenUpgradeChoiceMenu
    OpenUpgradeChoiceMenu = function( ... )
        local rv = origOpen( ... )
        thread( function()
            wait( 0.5 ) -- Wait for menu animations to finish
            
            local anchor = CreateScreenComponent({ 
                Name = "BlankObstacle", 
                Group = "Combat_Menu_Overlay", -- Guaranteed top layer
                X = ScreenCenterX, 
                Y = ScreenCenterY - 350 -- Positioned at the top of the boon menu
            })
            
            CreateTextBox({
                Id = anchor.Id,
                Text = "HADES HELPER ACTIVE",
                Color = { 1, 0.84, 0, 1 }, -- Gold
                FontSize = 32,
                Justification = "Center",
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 3 },
                OutlineThickness = 3,
            })
            
            -- Save anchor so we can destroy it later
            ScreenAnchors.HadesHelperTitle = anchor
        end )
        return rv
    end

    -- 2. Hook closing the boon screen to clean up our UI
    local origClose = CloseUpgradeChoiceScreen
    CloseUpgradeChoiceScreen = function( screen, button )
        if ScreenAnchors.HadesHelperTitle then
            DestroyTextBox({ Id = ScreenAnchors.HadesHelperTitle.Id })
            Destroy({ Id = ScreenAnchors.HadesHelperTitle.Id })
            ScreenAnchors.HadesHelperTitle = nil
        end
        return origClose( screen, button )
    end

end }

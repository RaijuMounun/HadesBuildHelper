-- HadesBuildHelper - UI Rendering Diagnostic
ModUtil.Mod.Register("HadesHelper")

-- Let's test if we can draw UI on command.
-- Pressing 'Reload' (R on keyboard) will attempt to spawn a text box.
OnControlPressed{ "Reload", function( triggerArgs )
    if CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead then
        -- 1. Create a transparent anchor on the absolute top layer
        local anchor = CreateScreenComponent({ 
            Name = "BlankObstacle", 
            Group = "Combat_Menu_Overlay", 
            X = ScreenCenterX, 
            Y = ScreenCenterY - 200 
        })
        
        -- 2. Attach text to it
        CreateTextBox({
            Id = anchor.Id,
            Text = "UI RENDERING WORKS!",
            Color = { 1, 0.2, 0.2, 1 }, -- Bright red
            FontSize = 44,
            Justification = "Center",
            ShadowColor = { 0, 0, 0, 1 },
            ShadowOffset = { 0, 3 },
            OutlineThickness = 3,
        })
        
        PlaySound({ Name = "/SFX/Menu Sounds/SellTraitShop" })
    end
end }

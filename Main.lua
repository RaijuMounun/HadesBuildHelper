-- HadesBuildHelper - Minimal diagnostic test
ModUtil.Mod.Register("HadesHelper")

ModUtil.Path.Wrap("OpenUpgradeChoiceMenu", function(base, ...)
    base(...)
    thread(function()
        wait(0.5)
        -- Attach to Hero's object - always exists, guaranteed visible
        if CurrentRun and CurrentRun.Hero then
            CreateTextBox({
                Id = CurrentRun.Hero.ObjectId,
                Text = "HH Active",
                Color = { 1, 1, 0, 1 },
                OffsetX = 0,
                OffsetY = -120,
                FontSize = 28,
                Justification = "Center",
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 2 },
                OutlineThickness = 3,
            })
        end
    end)
end)

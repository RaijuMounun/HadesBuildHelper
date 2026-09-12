-- HadesBuildHelper - Absolute bulletproof execution test
ModUtil.Mod.Register("HadesHelper")

-- No UI, no hooks, no complex logic.
-- If the mod is running, pressing 'Reload' (R on keyboard, X/Square on controller)
-- will immediately give 500 gold and play a cash register sound.
OnControlPressed{ "Reload", function( triggerArgs )
    if CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead then
        AddMoney( 500, "HadesHelper Diagnostic" )
        PlaySound({ Name = "/SFX/Menu Sounds/SellTraitShop" })
    end
end }

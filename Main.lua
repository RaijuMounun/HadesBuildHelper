-- HadesBuildHelper - Main Entry
ModUtil.Mod.Register("HadesHelper")
HadesHelper = HadesHelper or {}

OnAnyLoad{ function( triggerArgs )
    if HadesHelper.Initialized then return end
    HadesHelper.Initialized = true

    local origCreateButtons = CreateBoonLootButtons
    CreateBoonLootButtons = function( lootData, reroll )
        local rv = origCreateButtons( lootData, reroll )
        
        thread( function()
            wait( 0.2 )
            
            if ScreenAnchors.ChoiceScreen and ScreenAnchors.ChoiceScreen.Components then
                local components = ScreenAnchors.ChoiceScreen.Components
                
                local successState, parsedState = pcall(function()
                    return StateReader.Parse(CurrentRun, GameState)
                end)
                if not successState then 
                    parsedState = { HealthPercent = 1.0, GodPool = {}, GodCount = 0, Aspect = "Base", WeaponName = "SwordWeapon" } 
                end
                
                local viable_builds = {}
                pcall(function()
                    viable_builds = EVSimulator.CalculateViability(WeaponBlueprints, parsedState)
                end)
                
                local pool_penalty = parsedState.GodCount >= 4
                
                for i = 1, 3 do
                    local buttonKey = "PurchaseButton"..i
                    if components[buttonKey] then
                        local scoreText = "[ ERR ]"
                        
                        pcall(function()
                            if lootData and lootData.UpgradeOptions and lootData.UpgradeOptions[i] then
                                local traitName = lootData.UpgradeOptions[i].ItemName
                                
                                local base_score = ScoringEngine.evaluate_boon(traitName, viable_builds)
                                local rarity_mod = 1.0
                                if lootData.UpgradeOptions[i].Rarity == "Rare" then rarity_mod = 1.2
                                elseif lootData.UpgradeOptions[i].Rarity == "Epic" then rarity_mod = 1.4
                                elseif lootData.UpgradeOptions[i].Rarity == "Heroic" then rarity_mod = 1.6
                                elseif lootData.UpgradeOptions[i].Rarity == "Legendary" then rarity_mod = 2.0 end
                                
                                local score = ScoringEngine.calculate_score(base_score, rarity_mod, parsedState.HealthPercent, pool_penalty)
                                local final_score_int = math.floor(score * 100 + 0.5)
                                scoreText = "[ " .. tostring(final_score_int) .. "% ]"
                                
                                local scoreColor = { 0.5, 0.5, 0.5, 1 }
                                if final_score_int >= 80 then
                                    scoreColor = { 1, 0.84, 0, 1 }
                                elseif final_score_int >= 50 then
                                    scoreColor = { 1, 1, 1, 1 }
                                end
                                
                                CreateTextBox({
                                    Id = components[buttonKey].Id,
                                    Text = scoreText,
                                    Color = scoreColor,
                                    OffsetX = 300,
                                    OffsetY = -50,
                                    FontSize = 24,
                                    Justification = "Right",
                                    ShadowColor = { 0, 0, 0, 1 },
                                    ShadowOffset = { 0, 2 },
                                    OutlineThickness = 3,
                                })
                            end
                        end)
                    end
                end
            end
        end )
        return rv
    end

end }

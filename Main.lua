-- HadesBuildHelper - Main Entry
ModUtil.Mod.Register("HadesHelper")
HadesHelper = HadesHelper or {}

-- We use OnAnyLoad to ensure our hooks run AFTER all game scripts are loaded
OnAnyLoad{ function( triggerArgs )
    if HadesHelper.Initialized then return end
    HadesHelper.Initialized = true

    -- Hook the exact function that creates the boon cards
    local origCreateButtons = CreateBoonLootButtons
    CreateBoonLootButtons = function( lootData, reroll )
        local rv = origCreateButtons( lootData, reroll )
        
        thread( function()
            wait( 0.2 ) -- Give the game a fraction of a second to spawn the buttons
            
            if ScreenAnchors.ChoiceScreen and ScreenAnchors.ChoiceScreen.Components then
                local components = ScreenAnchors.ChoiceScreen.Components
                
                local successState, parsedState = pcall(function()
                    return StateReader.Parse(CurrentRun)
                end)
                if not successState then parsedState = { HealthPercent = 1.0, GodPool = {}, GodCount = 0 } end
                
                local valid_blueprints = Blueprints or {}
                pcall(function()
                    local active_gods = {}
                    for god, _ in pairs(parsedState.GodPool) do
                        table.insert(active_gods, god)
                    end
                    valid_blueprints = EVSimulator.PruneBlueprints(Blueprints, active_gods)
                end)
                
                local pool_penalty = parsedState.GodCount >= 4
                
                -- Hades creates 3 buttons named PurchaseButton1, PurchaseButton2, PurchaseButton3
                for i = 1, 3 do
                    local buttonKey = "PurchaseButton"..i
                    if components[buttonKey] then
                        local score = 0
                        local scoreText = "SCORE: ERR"
                        
                        pcall(function()
                            if lootData and lootData.UpgradeOptions and lootData.UpgradeOptions[i] then
                                local traitName = lootData.UpgradeOptions[i].ItemName
                                
                                local base_score = ScoringEngine.evaluate_boon(traitName, valid_blueprints)
                                local rarity_mod = 1.0
                                if lootData.UpgradeOptions[i].Rarity == "Rare" then rarity_mod = 1.2
                                elseif lootData.UpgradeOptions[i].Rarity == "Epic" then rarity_mod = 1.4
                                elseif lootData.UpgradeOptions[i].Rarity == "Heroic" then rarity_mod = 1.6
                                elseif lootData.UpgradeOptions[i].Rarity == "Legendary" then rarity_mod = 2.0 end
                                
                                score = ScoringEngine.calculate_score(base_score, rarity_mod, parsedState.HealthPercent, pool_penalty)
                                local final_score_int = math.floor(score * 100)
                                scoreText = "SCORE: " .. tostring(final_score_int)
                                
                                -- Dynamic Colors
                                local scoreColor = { 0.5, 0.5, 0.5, 1 } -- Dark Gray (Ignore)
                                if final_score_int >= 80 then
                                    scoreColor = { 1, 0.84, 0, 1 } -- Gold (Must Pick)
                                elseif final_score_int >= 50 then
                                    scoreColor = { 1, 1, 1, 1 } -- White (Good)
                                end
                                
                                -- Attach our text DIRECTLY to the boon card!
                                CreateTextBox({
                                    Id = components[buttonKey].Id,
                                    Text = scoreText,
                                    Color = scoreColor,
                                    OffsetX = 300,          -- Push it to the right side of the card
                                    OffsetY = -50,          -- Slightly above the center of the card
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

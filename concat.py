import os

with open('Data/Blueprints.lua', 'r', encoding='utf-8') as f: blueprints = f.read()
with open('Engine/StateReader.lua', 'r', encoding='utf-8') as f: state_reader = f.read()
with open('Engine/ScoringEngine.lua', 'r', encoding='utf-8') as f: scoring_engine = f.read()
with open('Engine/EVSimulator.lua', 'r', encoding='utf-8') as f: ev_simulator = f.read()

# Fix globals
blueprints = blueprints.replace("WeaponBlueprints = {", "local WeaponBlueprints = {")
state_reader = state_reader.replace("StateReader = StateReader or {}", "local StateReader = {}")
scoring_engine = scoring_engine.replace("ScoringEngine = ScoringEngine or {}", "local ScoringEngine = {}")
ev_simulator = ev_simulator.replace("EVSimulator = EVSimulator or {}", "local EVSimulator = {}")

main_code = """
-- HadesBuildHelper - Main Entry
OnAnyLoad{ function( triggerArgs )
    
    ---------------------------------------------------------------------------
    -- 1. BOON LOOT HOOK (Daedalus, Boons, Poms)
    ---------------------------------------------------------------------------
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
                        local scoreText = ""
                        local scoreColor = { 1, 0, 0, 1 }
                        
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
                                scoreText = "SCORE: " .. tostring(final_score_int)
                                
                                scoreColor = { 0.5, 0.5, 0.5, 1 }
                                if final_score_int >= 80 then
                                    scoreColor = { 1, 0.84, 0, 1 }
                                elseif final_score_int >= 50 then
                                    scoreColor = { 1, 1, 1, 1 }
                                end
                            end
                        end)
                        
                        if scoreText ~= "" then
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
                    end
                end
            end
        end )
        return rv
    end

    ---------------------------------------------------------------------------
    -- 2. WELL OF CHARON (Store Screen) HOOK
    ---------------------------------------------------------------------------
    local origCreateStoreButtons = CreateStoreButtons
    CreateStoreButtons = function()
        local rv = origCreateStoreButtons()
        
        thread( function()
            wait( 0.2 )
            if CurrentRun.CurrentRoom.Store and CurrentRun.CurrentRoom.Store.Screen and CurrentRun.CurrentRoom.Store.Screen.Components then
                local components = CurrentRun.CurrentRoom.Store.Screen.Components
                for i = 1, 3 do
                    local buttonKey = "PurchaseButton"..i
                    if components[buttonKey] then
                        CreateTextBox({
                            Id = components[buttonKey].Id,
                            Text = "[ WELL ]", 
                            Color = { 1, 0.5, 0, 1 },
                            OffsetX = 300,
                            OffsetY = -50,
                            FontSize = 24,
                            Justification = "Right",
                            ShadowColor = { 0, 0, 0, 1 },
                            ShadowOffset = { 0, 2 },
                            OutlineThickness = 3,
                        })
                    end
                end
            end
        end )
        return rv
    end

    ---------------------------------------------------------------------------
    -- 3. CHARON MID-RUN SHOP (Physical Floor Items) HOOK
    ---------------------------------------------------------------------------
    local origSpawnStoreItemsInWorld = SpawnStoreItemsInWorld
    SpawnStoreItemsInWorld = function()
        origSpawnStoreItemsInWorld()
        
        thread( function()
            wait( 0.5 )
            if CurrentRun.CurrentRoom.Store and CurrentRun.CurrentRoom.Store.SpawnedStoreItems then
                for _, item in ipairs(CurrentRun.CurrentRoom.Store.SpawnedStoreItems) do
                    if item.ObjectId then
                        local anchorId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = item.ObjectId })
                        Attach({ Id = anchorId, DestinationId = item.ObjectId, OffsetY = -150 })
                        CreateTextBox({
                            Id = anchorId,
                            Text = "[ FLOOR ]",
                            Color = { 1, 1, 0, 1 },
                            FontSize = 28,
                            Justification = "Center",
                            ShadowColor = { 0, 0, 0, 1 },
                            ShadowOffset = { 0, 2 },
                            OutlineThickness = 3,
                        })
                    end
                end
            end
        end )
    end

    ---------------------------------------------------------------------------
    -- 4. ROOM REWARD DOORS HOOK
    ---------------------------------------------------------------------------
    if CreateDoorRewardPreview then
        local origCreateDoorRewardPreview = CreateDoorRewardPreview
        CreateDoorRewardPreview = function( exitDoor )
            origCreateDoorRewardPreview( exitDoor )
            
            thread( function()
                wait( 0.5 )
                if exitDoor and exitDoor.ObjectId then
                    local anchorId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = exitDoor.ObjectId })
                    Attach({ Id = anchorId, DestinationId = exitDoor.ObjectId, OffsetY = -200 })
                    CreateTextBox({
                        Id = anchorId,
                        Text = "[ DOOR ]",
                        Color = { 0, 1, 1, 1 },
                        FontSize = 28,
                        Justification = "Center",
                        ShadowColor = { 0, 0, 0, 1 },
                        ShadowOffset = { 0, 2 },
                        OutlineThickness = 3,
                    })
                end
            end )
        end
    end

end }
"""

with open('Main.lua', 'w', encoding='utf-8') as f:
    f.write(blueprints + '\n' + state_reader + '\n' + scoring_engine + '\n' + ev_simulator + '\n' + main_code)

with open('modfile.txt', 'w', encoding='utf-8') as f:
    f.write(':: Hades Build Helper Mod\n\nTo "Scripts/Main.lua"\n\tImport "Main.lua"\n')

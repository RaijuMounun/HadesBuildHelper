local WeaponBlueprints = {
    FistWeapon = {
        Base = {
            {
                Name = "Merciful End Fists",
                Components = { AresWeaponTrait = 1.0, AthenaSecondaryTrait = 1.0, AthenaRushTrait = 0.5, TriggerCurseTrait = 1.0, AresLongCurseTrait = 0.5, AresLoadCurseTrait = 0.5 },
                RequiredGods = { "Ares", "Athena" }
            }
        }
    },
    GunWeapon = {
        Eris = {
            {
                Name = "Sea-Storm Eris",
                Components = { ZeusWeaponTrait = 1.0, PoseidonSecondaryTrait = 1.0, ImpactBoltTrait = 1.0, ZeusLightningDebuff = 0.8, SlipperyTrait = 0.8 },
                RequiredGods = { "Zeus", "Poseidon" }
            }
        }
    },
    BowWeapon = {
        Chiron = {
            {
                Name = "Heart Rend Chiron",
                Components = { AphroditeWeaponTrait = 1.0, ArtemisSecondaryTrait = 1.0, HeartsickCritDamageTrait = 1.0, CritVulnerabilityTrait = 1.0, BowSecondaryBarrageTrait = 0.5, BowConsecutiveBarrageTrait = 0.5 },
                RequiredGods = { "Aphrodite", "Artemis" }
            }
        }
    },
    ShieldWeapon = {
        Beowulf = {
            {
                Name = "Mirage Flare Beowulf",
                Components = { ShieldLoadAmmo_DionysusRangedTrait = 1.0, PoseidonRangedTrait = 0.5, ArtemisWeaponTrait = 1.0, ArtemisBonusProjectileTrait = 1.0, CritBonusTrait = 0.8 },
                RequiredGods = { "Dionysus", "Poseidon", "Artemis" }
            }
        }
    },
    SpearWeapon = {
        Achilles = {
            {
                Name = "Hunting Blades Achilles",
                Components = { AresRangedTrait = 1.0, ArtemisWeaponTrait = 1.0, AresHomingTrait = 1.0, AresDragTrait = 0.8, AresAoETrait = 0.8 },
                RequiredGods = { "Ares", "Artemis" }
            }
        }
    },
    SwordWeapon = {
        Nemesis = {
            {
                Name = "Heart Rend Nemesis",
                Components = { AphroditeWeaponTrait = 1.0, ArtemisSecondaryTrait = 1.0, ArtemisRushTrait = 0.8, HeartsickCritDamageTrait = 1.0, CritVulnerabilityTrait = 1.0, SwordDoubleDashAttackTrait = 1.0, SwordCriticalTrait = 0.5 },
                RequiredGods = { "Aphrodite", "Artemis" }
            }
        },
        Base = {
            {
                Name = "Base Sword Generic DPS",
                Components = { ZeusWeaponTrait = 1.0, PoseidonSecondaryTrait = 0.8, AthenaRushTrait = 1.0, SwordDoubleDashAttackTrait = 1.0, SwordHeavySecondStrikeTrait = 0.7 },
                RequiredGods = {}
            }
        }
    }
}

local StateReader = {}

local PrimaryWeapons = {
    SwordWeapon = true,
    SpearWeapon = true,
    ShieldWeapon = true,
    BowWeapon = true,
    FistWeapon = true,
    GunWeapon = true
}

function StateReader.Parse(currentRun, gameState)
    local state = {
        HealthPercent = 1.0,
        GodPool = {},
        GodCount = 0,
        Keepsake = nil,
        MirrorUpgrades = {},
        Aspect = "Base"
    }
    
    if gameState then
        state.Keepsake = gameState.LastAwardTrait
        if gameState.MetaUpgradesSelected then
            for upgrade, _ in pairs(gameState.MetaUpgradesSelected) do
                state.MirrorUpgrades[upgrade] = true
            end
        end
    end
    
    if currentRun and currentRun.Hero then
        local hp = currentRun.Hero.Health or 100
        local maxHp = currentRun.Hero.MaxHealth or 100
        if maxHp > 0 then
            state.HealthPercent = hp / maxHp
        end
        
        if currentRun.Hero.WeaponName then
            state.WeaponName = currentRun.Hero.WeaponName
        elseif type(currentRun.Hero.Weapons) == "table" then
            for weaponName, _ in pairs(currentRun.Hero.Weapons) do
                if PrimaryWeapons[weaponName] then
                    state.WeaponName = weaponName
                    break
                end
            end
            if not state.WeaponName then
                for weaponName, _ in pairs(currentRun.Hero.Weapons) do
                    state.WeaponName = weaponName
                    break
                end
            end
        end

        if currentRun.Hero.Traits then
            for _, trait in ipairs(currentRun.Hero.Traits) do
                local traitName = type(trait) == "table" and trait.Name or trait
                if type(traitName) == "string" then
                    if traitName == "SwordCritTrait" then state.Aspect = "Nemesis"
                    elseif traitName == "SwordLifestealTrait" then state.Aspect = "Arthur"
                    elseif traitName == "GunGrenadeTrait" then state.Aspect = "Eris"
                    elseif traitName == "BowSpecialBarrageTrait" then state.Aspect = "Chiron"
                    elseif traitName == "ShieldLoadAmmoTrait" then state.Aspect = "Beowulf"
                    elseif traitName == "SpearTeleportTrait" then state.Aspect = "Achilles"
                    end
                end
            end
        end
    end
    
    if currentRun and currentRun.LootTypeHistory then
        for _, god in ipairs(currentRun.LootTypeHistory) do
            if not state.GodPool[god] then
                state.GodPool[god] = true
                state.GodCount = state.GodCount + 1
            end
        end
    end
    
    return state
end

local ScoringEngine = {}

local function curve_polynomial(x, exponent)
    return x ^ exponent
end

function ScoringEngine.calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    local panic_factor = curve_polynomial(1.0 - health_percent, 2.0)
    local state_mod = 1.0 + (panic_factor * 4.0)
    local pool_mod = pool_penalty_active and 0.01 or 1.00

    local final = base_score * rarity_mod * state_mod * pool_mod
    return math.min(1.0, math.max(0.0, final))
end

function ScoringEngine.evaluate_boon(boon_name, viable_builds)
    local total_score = 0.0
    for _, vb in ipairs(viable_builds) do
        if vb.Blueprint.Components and vb.Blueprint.Components[boon_name] then
            total_score = total_score + (vb.Blueprint.Components[boon_name] * vb.Viability)
        end
    end
    
    if total_score > 0 then
        -- Normalize the final score to a [0.0, 1.0] range using a simple divisor limit
        return math.min(1.0, total_score / 2.0)
    else
        return 0.1
    end
end

local EVSimulator = {}

local CoreGods = {
    Zeus = true, Poseidon = true, Athena = true, Aphrodite = true,
    Artemis = true, Ares = true, Dionysus = true, Demeter = true
}

function EVSimulator.CalculateViability(weapon_blueprints, parsedState)
    local results = {}
    
    local weapon_bps = weapon_blueprints[parsedState.WeaponName]
    if not weapon_bps then return results end
    
    local builds_to_eval = {}
    if parsedState.Aspect and weapon_bps[parsedState.Aspect] then
        for _, bp in ipairs(weapon_bps[parsedState.Aspect]) do
            table.insert(builds_to_eval, bp)
        end
    end
    if parsedState.Aspect ~= "Base" and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do
            table.insert(builds_to_eval, bp)
        end
    end
    if parsedState.Aspect == nil and weapon_bps["Base"] then
        for _, bp in ipairs(weapon_bps["Base"]) do
            table.insert(builds_to_eval, bp)
        end
    end

    local active_god_count = parsedState.GodCount or 0
    local active_gods = parsedState.GodPool or {}
    local keepsake = parsedState.Keepsake

    for _, bp in ipairs(builds_to_eval) do
        local viability = 1.0
        
        local required_new_gods = 0
        local god_match_score = 0
        if bp.RequiredGods then
            for _, bgod in ipairs(bp.RequiredGods) do
                if active_gods[bgod] then
                    god_match_score = god_match_score + 1
                else
                    required_new_gods = required_new_gods + 1
                end
                
                -- Keepsake bump
                if keepsake and string.find(keepsake, bgod) then
                    viability = viability + 0.5
                end
            end
            
            if active_god_count + required_new_gods > 4 and required_new_gods > 0 then
                viability = viability * 0.1
            end
            
            if #bp.RequiredGods > 0 then
                viability = viability * (1.0 + (god_match_score / #bp.RequiredGods))
            end
        end
        
        table.insert(results, { Blueprint = bp, Viability = viability })
    end
    
    return results
end


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

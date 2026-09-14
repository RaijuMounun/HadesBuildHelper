-- StateReader.lua
StateReader = StateReader or {}

function StateReader.Parse(currentRun)
    local state = {
        HealthPercent = 1.0,
        GodPool = {},
        GodCount = 0
    }
    
    if currentRun and currentRun.Hero then
        local hp = currentRun.Hero.Health or 100
        local maxHp = currentRun.Hero.MaxHealth or 100
        if maxHp > 0 then
            state.HealthPercent = hp / maxHp
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

ScoringEngine = ScoringEngine or {}

local function curve_polynomial(x, exponent)
    return x ^ exponent
end

function ScoringEngine.calculate_score(base_score, rarity_mod, health_percent, pool_penalty_active)
    -- Panic State: inverse polynomial curve
    local panic_factor = curve_polynomial(1.0 - health_percent, 2.0)
    -- Panic modifier scales from 1x (at 100% HP) up to 5x (at 0% HP)
    local state_mod = 1.0 + (panic_factor * 4.0)
    
    local pool_mod = pool_penalty_active and 0.01 or 1.00

    local final = base_score * rarity_mod * state_mod * pool_mod
    -- Clamp between 0.0 and 1.0
    return math.min(1.0, math.max(0.0, final))
end

function ScoringEngine.evaluate_boon(boon_name, blueprints)
    local max_score = 0.0
    for _, blueprint in ipairs(blueprints) do
        for _, core_trait in ipairs(blueprint.CoreTraits) do
            if core_trait == boon_name then
                max_score = math.max(max_score, 1.0)
            end
        end
    end
    -- Return a minimal score if it's not a core trait in any blueprint
    if max_score > 0 then
        return max_score
    else
        return 0.1
    end
end

EVSimulator = EVSimulator or {}

local CoreGods = {
    Zeus = true,
    Poseidon = true,
    Athena = true,
    Aphrodite = true,
    Artemis = true,
    Ares = true,
    Dionysus = true,
    Demeter = true
}

function EVSimulator.PruneBlueprints(blueprints, active_gods)
    local active_count = 0
    local god_set = {}
    
    if active_gods then
        for _, god in ipairs(active_gods) do
            if CoreGods[god] and not god_set[god] then
                god_set[god] = true
                active_count = active_count + 1
            end
        end
    end

    local valid_blueprints = {}
    for _, bp in ipairs(blueprints) do
        local required_new_gods = 0
        if bp.Gods then
            for _, bgod in ipairs(bp.Gods) do
                if CoreGods[bgod] and not god_set[bgod] then
                    required_new_gods = required_new_gods + 1
                end
            end
        end
        
        -- If we have fewer than 4 gods, we can add new ones up to the limit of 4.
        -- If we already have 4 or more gods, we can only pursue blueprints that don't add new gods.
        if active_count + required_new_gods <= 4 or required_new_gods == 0 then
            table.insert(valid_blueprints, bp)
        end
    end
    
    return valid_blueprints
end

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
                                scoreText = "SCORE: " .. tostring(math.floor(score * 100))
                            end
                        end)
                        
                        -- Attach our text DIRECTLY to the boon card!
                        CreateTextBox({
                            Id = components[buttonKey].Id,
                            Text = scoreText,
                            Color = { 0, 1, 0, 1 }, -- Green
                            OffsetX = 300,          -- Push it to the right side of the card
                            OffsetY = -50,          -- Slightly above the center of the card
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

end }

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
                
                -- Hades creates 3 buttons named PurchaseButton1, PurchaseButton2, PurchaseButton3
                for i = 1, 3 do
                    local buttonKey = "PurchaseButton"..i
                    if components[buttonKey] then
                        -- Attach our text DIRECTLY to the boon card!
                        CreateTextBox({
                            Id = components[buttonKey].Id,
                            Text = "SCORE: 95",
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

-- GameDataParser.lua
GameDataParser = GameDataParser or {}

function GameDataParser.ParseTraits(traitData)
    local parsed = {}
    if not traitData then return parsed end
    
    for k, v in pairs(traitData) do
        parsed[k] = {
            Name = v.Name or k,
            God = v.God or "None",
            Slot = v.Slot or "None"
        }
    end
    
    return parsed
end

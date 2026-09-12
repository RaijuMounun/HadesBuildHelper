-- MockGameData.lua
local MockGameData = {}

MockGameData.TraitData = {
    ZeusWeaponBoon = { Name = "ZeusWeaponBoon", God = "Zeus", Slot = "Melee" },
    AthenaWeaponBoon = { Name = "AthenaWeaponBoon", God = "Athena", Slot = "Ranged" }
}

MockGameData.CurrentRun = {
    Hero = {
        Health = 25,
        MaxHealth = 100,
        Traits = {
            MockGameData.TraitData.ZeusWeaponBoon
        }
    },
    LootTypeHistory = { "Zeus", "Athena", "Ares", "Aphrodite" }
}

return MockGameData

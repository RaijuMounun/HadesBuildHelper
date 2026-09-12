-- MockGameData.lua
local MockGameData = {}

MockGameData.TraitData = {
    ZeusWeaponBoon = { Name = "ZeusWeaponBoon", God = "Zeus", Slot = "Melee" },
    AthenaWeaponBoon = { Name = "AthenaWeaponBoon", God = "Athena", Slot = "Ranged" },
    PoseidonWeaponBoon = { Name = "PoseidonWeaponBoon", God = "Poseidon", Slot = "Dash" },
    AresWeaponBoon = { Name = "AresWeaponBoon", God = "Ares", Slot = "Cast" },
    SeaStormDuo = { Name = "SeaStormDuo", God = "Duo", Slot = "Passive" },
    MercifulEndDuo = { Name = "MercifulEndDuo", God = "Duo", Slot = "Passive" }
}

MockGameData.CurrentRun = {
    Hero = {
        Health = 25,
        MaxHealth = 100,
        Traits = {
            MockGameData.TraitData.ZeusWeaponBoon
        }
    },
    LootTypeHistory = { "Zeus", "Athena", "Ares", "Hermes" }
}

return MockGameData

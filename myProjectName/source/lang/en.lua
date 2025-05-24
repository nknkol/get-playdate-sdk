
-- lang/en.lua (增强版)
return {
    ui = { 
        title = "Dungeon Demo", 
        prompt = "Choose action:",
        skillPanel = "⚡ Skill Info",
        closeHint = "Press A or B to close"
    },
    menu = { "Attack", "Taunt", "Flee" },
    skills = {
        ["Attack"] = {
            desc = "Deal physical damage to enemy",
            cost = "Cost: None",
            effect = "Damage: 10-15"
        },
        ["Taunt"] = {
            desc = "Force enemy to attack you, increase defense",
            cost = "Cost: 5 MP",
            effect = "Defense+3, 2 turns"
        },
        ["Flee"] = {
            desc = "Attempt to escape from battle",
            cost = "Cost: None",
            effect = "Success: 70%"
        }
    }
}
-- lang/en.lua (增强版 - 支持多层菜单)
return {
    ui = { 
        title = "Dungeon Demo", 
        prompt = "Choose action:",
        skillPanel = "⚡ Skill Info",
        closeHint = "Hold B to close",
        backHint = "Press B to back",
        levelHint = "Level"
    },
    menu = { "Attack", "Taunt", "Flee" },
    
    -- 子菜单定义
    subMenus = {
        attack_target = {
            title = "Select target:",
            options = { "Goblin", "Skeleton", "Mage", "Shadow Assassin" }
        },
        flee_confirm = {
            title = "Confirm retreat?",
            options = { "Confirm", "Cancel" }
        },
        magic_spells = {
            title = "Choose spell:",
            options = { "Fireball", "Heal", "Ice Shard", "Lightning Chain" }
        }
    },
    
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
    },
    
    -- 操作提示文本
    hints = {
        mainMenu = "A to confirm | Hold ↑↓ for panels",
        subMenu = "A to confirm | Press B to back",
        panelVisible = "Hold B to close panel",
        longPressB = "Hold B to close panel...",
        longPressUp = "Hold to show skill panel...",
        longPressDown = "Hold to show attribute panel..."
    }
}
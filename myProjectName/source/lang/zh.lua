-- lang/zh.lua (增强版)
return {
    ui = { 
        title = "Dungeon Demo", 
        prompt = "请选择行动：",
        skillPanel = "⚡ 技能说明",
        closeHint = "按 A 或 B 键关闭"
    },
    menu = { "攻击", "嘲讽", "撤退" },
    skills = {
        ["攻击"] = {
            desc = "对敌人造成物理伤害",
            cost = "消耗: 无",
            effect = "伤害: 10-15"
        },
        ["嘲讽"] = {
            desc = "强制敌人攻击自己，提高防御",
            cost = "消耗: 5 MP",
            effect = "防御+3，持续2回合"
        },
        ["撤退"] = {
            desc = "尝试逃离战斗",
            cost = "消耗: 无",
            effect = "成功率: 70%"
        }
    }
}
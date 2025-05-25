-- =====================================================
-- lang/zh.lua - 中文语言包
-- =====================================================

return {
    -- ===== 界面文本区域 =====
    ui = { 
        title = "Dungeon Demo", 
        prompt = "请选择行动：",
        skillPanel = "⚡ 技能说明",
        closeHint = "长按 B 键关闭",
        backHint = "短按 B 键返回",
        levelHint = "层级",
    },
    
    -- ===== 主菜单区域 =====
    menu = { "攻击", "嘲讽", "撤退" },
    
    -- ===== 子菜单定义区域 =====
    subMenus = {
        attack_target = {
            title = "选择攻击目标：",
            options = { "哥布林", "骷髅兵", "魔法师", "暗影刺客" }
        },
        flee_confirm = {
            title = "确认要撤退吗？",
            options = { "确认撤退", "取消" }
        },
        magic_spells = {
            title = "选择魔法：",
            options = { "火球术", "治愈术", "冰锥术", "闪电链" }
        }
    },
    
    -- ===== 技能信息区域 =====
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
    },
    
    -- ===== 操作提示区域 =====
    hints = {
        mainMenu = "A键确认 | 长按↑↓查看面板",
        subMenu = "A键确认 | 短按B键返回",
        panelVisible = "长按B键关闭面板",
        longPressB = "长按B键关闭面板...",
        longPressUp = "长按显示技能面板...",
        longPressDown = "长按显示属性面板..."
    }
}

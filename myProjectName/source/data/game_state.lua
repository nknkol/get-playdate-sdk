-- source/data/game_state.lua
local state = {
    currentMode   = "main_sentence",
    selectedIndex = 1,
    showStatus    = true,
    showAttribute = false,
    showSkill     = false,  -- 技能面板显示状态
    
    -- 屏幕滑动相关
    screenOffset = 0,           -- 当前屏幕Y偏移量（负值=上移，正值=下移）
    targetOffset = 0,           -- 目标偏移量
    attributePanelHeight = 70,  -- 属性面板高度（底部）
    skillPanelHeight = 80,      -- 技能面板高度（顶部）
    animationSpeed = 8,         -- 动画速度
    
    -- 长按检测
    downButtonHoldTime = 0,     -- 下键按住时间
    upButtonHoldTime = 0,       -- 上键按住时间
    bButtonHoldTime = 0,        -- B键按住时间（新增）
    longPressThreshold = 30,    -- 长按阈值（帧数，约0.5秒）
    
    -- 菜单层级管理（新增）
    menuStack = {},             -- 菜单堆栈，存储菜单历史
    currentMenuId = "main",     -- 当前菜单ID
    currentMenuData = nil,      -- 当前菜单数据
}

-- 菜单管理函数（新增）
function state.pushMenu(menuId, menuData, selectedIndex)
    -- 将当前菜单状态压入堆栈
    table.insert(state.menuStack, {
        id = state.currentMenuId,
        data = state.currentMenuData,
        selectedIndex = state.selectedIndex
    })
    
    -- 切换到新菜单
    state.currentMenuId = menuId
    state.currentMenuData = menuData
    state.selectedIndex = selectedIndex or 1
end

function state.popMenu()
    -- 从堆栈中弹出上一个菜单
    if #state.menuStack > 0 then
        local prevMenu = table.remove(state.menuStack)
        state.currentMenuId = prevMenu.id
        state.currentMenuData = prevMenu.data
        state.selectedIndex = prevMenu.selectedIndex
        return true
    end
    return false  -- 已经是根菜单
end

function state.clearMenuStack()
    -- 清空菜单堆栈，回到根菜单
    state.menuStack = {}
    state.currentMenuId = "main"
    state.currentMenuData = nil
    state.selectedIndex = 1
end

function state.isInSubMenu()
    -- 检查是否在子菜单中
    return #state.menuStack > 0
end

function state.getMenuDepth()
    -- 获取当前菜单深度
    return #state.menuStack
end

-- 工具函数
function state.isAttributeVisible()
    return state.targetOffset < 0  -- 负偏移表示属性面板可见
end

function state.isSkillVisible()
    return state.targetOffset > 0  -- 正偏移表示技能面板可见
end

function state.isPanelVisible()
    return state.isAttributeVisible() or state.isSkillVisible()
end

function state.showAttributePanel()
    state.targetOffset = -state.attributePanelHeight  -- 向上移动（负值）
    state.showAttribute = true
    state.showSkill = false
end

function state.hideAttributePanel()
    if state.isAttributeVisible() then
        state.targetOffset = 0
        state.showAttribute = false
    end
end

function state.showSkillPanel()
    state.targetOffset = state.skillPanelHeight  -- 向下移动（正值）
    state.showSkill = true
    state.showAttribute = false
end

function state.hideSkillPanel()
    if state.isSkillVisible() then
        state.targetOffset = 0
        state.showSkill = false
    end
end

function state.hideAllPanels()
    state.targetOffset = 0
    state.showAttribute = false
    state.showSkill = false
end

function state.updateAnimation()
    -- 平滑动画更新
    if math.abs(state.screenOffset - state.targetOffset) > 1 then
        state.screenOffset += (state.targetOffset - state.screenOffset) / state.animationSpeed
    else
        state.screenOffset = state.targetOffset
    end
end

return state
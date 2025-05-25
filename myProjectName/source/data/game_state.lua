-- data/game_state.lua - 游戏状态管理中心

-- ===== 核心状态数据区域 =====
local state = {
    -- --- 界面模式控制 ---
    currentMode   = "main_sentence",
    selectedIndex = 1,
    
    -- --- 面板显示状态 ---
    showStatus    = true,
    showAttribute = false,
    showSkill     = false,
    
    -- --- 屏幕动画参数 ---
    screenOffset = 0,           -- 当前屏幕Y偏移量（负值=上移，正值=下移）
    targetOffset = 0,           -- 目标偏移量
    attributePanelHeight = 70,  -- 属性面板高度（底部）
    skillPanelHeight = 80,      -- 技能面板高度（顶部）
    animationSpeed = 8,         -- 动画速度
    
    -- --- 按键长按检测 ---
    downButtonHoldTime = 0,     -- 下键按住时间
    upButtonHoldTime = 0,       -- 上键按住时间
    bButtonHoldTime = 0,        -- B键按住时间
    longPressThreshold = 30,    -- 长按阈值（帧数，约0.5秒）
    
    -- --- 菜单层级管理 ---
    menuStack = {},             -- 菜单堆栈，存储菜单历史
    currentMenuId = "main",     -- 当前菜单ID
    currentMenuData = nil,      -- 当前菜单数据
}

-- ===== 菜单堆栈管理区域 =====

-- --- 菜单入栈（进入子菜单）---
function state.pushMenu(menuId, menuData, selectedIndex)
    table.insert(state.menuStack, {
        id = state.currentMenuId,
        data = state.currentMenuData,
        selectedIndex = state.selectedIndex
    })
    
    state.currentMenuId = menuId
    state.currentMenuData = menuData
    state.selectedIndex = selectedIndex or 1
end

-- --- 菜单出栈（返回上级菜单）---
function state.popMenu()
    if #state.menuStack > 0 then
        local prevMenu = table.remove(state.menuStack)
        state.currentMenuId = prevMenu.id
        state.currentMenuData = prevMenu.data
        state.selectedIndex = prevMenu.selectedIndex
        return true
    end
    return false
end

-- --- 清空菜单栈（回到根菜单）---
function state.clearMenuStack()
    state.menuStack = {}
    state.currentMenuId = "main"
    state.currentMenuData = nil
    state.selectedIndex = 1
end

-- --- 菜单状态查询 ---
function state.isInSubMenu()
    return #state.menuStack > 0
end

function state.getMenuDepth()
    return #state.menuStack
end

-- ===== 面板状态工具函数区域 =====

-- --- 面板可见性检测 ---
function state.isAttributeVisible()
    return state.targetOffset < 0  -- 负偏移表示属性面板可见
end

function state.isSkillVisible()
    return state.targetOffset > 0  -- 正偏移表示技能面板可见
end

function state.isPanelVisible()
    return state.isAttributeVisible() or state.isSkillVisible()
end

-- ===== 面板控制操作区域 =====

-- --- 属性面板控制 ---
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

-- --- 技能面板控制 ---
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

-- --- 全部面板关闭 ---
function state.hideAllPanels()
    state.targetOffset = 0
    state.showAttribute = false
    state.showSkill = false
end

-- ===== 动画更新区域 =====
function state.updateAnimation()
    -- 平滑动画插值计算
    if math.abs(state.screenOffset - state.targetOffset) > 1 then
        state.screenOffset += (state.targetOffset - state.screenOffset) / state.animationSpeed
    else
        state.screenOffset = state.targetOffset
    end
end

return state
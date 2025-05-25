-- ui/main_area.lua - 主界面绘制区域

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics
local langMgr = LangMgr
local L
local function updateLang() L = langMgr.get() end

-- ===== 菜单数据获取区域 =====
local function getCurrentMenu()
    updateLang()
    
    if GameState.currentMenuId == "main" then
        return L.menu  -- 主菜单
    elseif GameState.currentMenuData then
        return GameState.currentMenuData  -- 自定义菜单数据
    else
        return L.menu  -- 默认返回主菜单
    end
end

-- --- 菜单标题获取 ---
local function getMenuTitle()
    if GameState.currentMenuId == "main" then
        return L.ui.prompt
    elseif GameState.currentMenuId == "attack_target" then
        return "选择攻击目标："
    elseif GameState.currentMenuId == "flee_confirm" then
        return "确认要撤退吗？"
    else
        return "请选择："
    end
end

-- ===== 主绘制函数区域 =====
local mainArea = {}
function mainArea.draw(state)
    updateLang()
    
    -- ===== 屏幕偏移计算区域 =====
    local offsetY = state.screenOffset  -- 正值=下移，负值=上移
    
    -- --- 裁剪区域设置 ---
    local clipY = 0
    local clipHeight = 240
    
    if state.isSkillVisible() then
        clipY = state.screenOffset
        clipHeight = 240 - state.screenOffset
    elseif state.isAttributeVisible() then
        clipHeight = 240 + state.screenOffset  -- screenOffset为负值
    end
    
    gfx.setClipRect(0, clipY, 400, clipHeight)
    
    -- ===== 标题和导航区域 =====
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(L.ui.title, 10, 5 + offsetY)
    
    -- --- 分割线 ---
    local separatorY = 20 + offsetY
    gfx.drawLine(10, separatorY, 390, separatorY)
    
    -- --- 菜单标题 ---
    local menuTitle = getMenuTitle()
    gfx.drawText(menuTitle, 10, 25 + offsetY)
    
    -- --- 菜单层级提示 ---
    if state.isInSubMenu() then
        local depthInfo = "层级: " .. (state.getMenuDepth() + 1) .. " | 短按B键返回"
        gfx.drawText(depthInfo, 10, 40 + offsetY)
    end

    -- ===== 当前选项显示区域 =====
    local currentMenu = getCurrentMenu()
    if currentMenu and currentMenu[state.selectedIndex] then
        local selectedOptionText = currentMenu[state.selectedIndex]
        local y = state.isInSubMenu() and 65 + offsetY or 50 + offsetY
        
        -- --- 高亮背景绘制 ---
        local w, h = gfx.getTextSize(selectedOptionText)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(8, y - 2, w + 4, h)
        
        -- --- 反色文字绘制 ---
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawText(selectedOptionText, 10, y)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
        -- --- 错误处理 ---
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("错误: 无法加载菜单", 10, 50 + offsetY)
    end
    
    -- ===== 操作提示区域 =====
    if not state.isPanelVisible() then
        local hintY = 180 + offsetY
        gfx.setColor(gfx.kColorBlack)
        
        -- --- 根据菜单状态显示不同提示 ---
        if state.isInSubMenu() then
            gfx.drawText("A键确认 | 短按B键返回", 10, hintY)
            gfx.drawText("长按 ↑ 键查看技能", 10, hintY + 15)
        else
            gfx.drawText("长按 ↑ 键查看技能", 10, hintY)
            gfx.drawText("长按 ↓ 键查看属性", 10, hintY + 15)
        end
    end
    
    -- ===== 长按进度指示器区域 =====
    
    -- --- 上键进度条（技能面板）---
    if state.upButtonHoldTime > state.longPressThreshold / 3 and not state.isPanelVisible() then
        local progress = state.upButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 30 + offsetY
        
        -- 进度条绘制
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按显示技能面板...", barX - 20, barY - 15)
    end
    
    -- --- 下键进度条（属性面板）---
    if state.downButtonHoldTime > state.longPressThreshold / 3 and not state.isPanelVisible() then
        local progress = state.downButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 220 + offsetY
        
        -- 进度条绘制
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按显示属性面板...", barX - 20, barY - 15)
    end
    
    -- --- B键进度条（关闭面板）---
    if state.bButtonHoldTime > state.longPressThreshold / 3 and state.isPanelVisible() then
        local progress = state.bButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 120 + offsetY
        
        -- 进度条绘制
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按关闭面板...", barX - 10, barY - 15)
    end
    
    -- ===== 面板状态提示区域 =====
    if state.isSkillVisible() and state.screenOffset >= state.skillPanelHeight * 0.9 then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("↑/↓ 切换技能 - 长按B键关闭", 10, 100 + offsetY)
    elseif state.isAttributeVisible() and math.abs(state.screenOffset) >= state.attributePanelHeight * 0.9 then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("↑/↓ 切换选项 - 长按B键关闭", 10, 150 + offsetY)
    end
    
    -- ===== 清理区域 =====
    gfx.clearClipRect()
end

return mainArea
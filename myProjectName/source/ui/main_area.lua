-- ui/main_area.lua
local gfx <const> = playdate.graphics
local langMgr = LangMgr
local L
local function updateLang() L = langMgr.get() end

-- 获取当前菜单数据
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

-- 获取菜单标题
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

local mainArea = {}
function mainArea.draw(state)
    updateLang()
    
    -- 计算Y轴偏移
    local offsetY = state.screenOffset  -- 正值=下移，负值=上移
    
    -- 设置裁剪区域，防止内容绘制到面板区域
    local clipY = 0
    local clipHeight = 240
    
    if state.isSkillVisible() then
        -- 技能面板显示时，从面板下方开始裁剪
        clipY = state.screenOffset
        clipHeight = 240 - state.screenOffset
    elseif state.isAttributeVisible() then
        -- 属性面板显示时，裁剪底部区域
        clipHeight = 240 + state.screenOffset  -- screenOffset为负值
    end
    
    gfx.setClipRect(0, clipY, 400, clipHeight)
    
    -- 标题与提示（考虑偏移）
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(L.ui.title, 10, 5 + offsetY)
    
    -- 添加分割线
    local separatorY = 20 + offsetY
    gfx.drawLine(10, separatorY, 390, separatorY)
    
    -- 显示当前菜单标题和层级信息
    local menuTitle = getMenuTitle()
    gfx.drawText(menuTitle, 10, 25 + offsetY)
    
    -- 显示菜单层级提示（如果在子菜单中）
    if state.isInSubMenu() then
        local depthInfo = "层级: " .. (state.getMenuDepth() + 1) .. " | 短按B键返回"
        gfx.drawText(depthInfo, 10, 40 + offsetY)
    end

    -- 显示当前选中的选项
    local currentMenu = getCurrentMenu()
    if currentMenu and currentMenu[state.selectedIndex] then
        local selectedOptionText = currentMenu[state.selectedIndex]
        local y = state.isInSubMenu() and 65 + offsetY or 50 + offsetY
        
        -- 绘制高亮背景
        local w, h = gfx.getTextSize(selectedOptionText)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(8, y - 2, w + 4, h)
        
        -- 绘制反色文字
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawText(selectedOptionText, 10, y)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
        -- 错误处理
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("错误: 无法加载菜单", 10, 50 + offsetY)
    end
    
    -- 显示操作提示（只有在没有面板显示时）
    if not state.isPanelVisible() then
        local hintY = 180 + offsetY
        gfx.setColor(gfx.kColorBlack)
        
        -- 根据是否在子菜单中显示不同的提示
        if state.isInSubMenu() then
            gfx.drawText("A键确认 | 短按B键返回", 10, hintY)
            gfx.drawText("长按 ↑ 键查看技能", 10, hintY + 15)
        else
            gfx.drawText("长按 ↑ 键查看技能", 10, hintY)
            gfx.drawText("长按 ↓ 键查看属性", 10, hintY + 15)
        end
    end
    
    -- 长按进度指示器 - 上键（技能面板）
    if state.upButtonHoldTime > state.longPressThreshold / 3 and not state.isPanelVisible() then
        local progress = state.upButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 30 + offsetY
        
        -- 绘制进度条
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按显示技能面板...", barX - 20, barY - 15)
    end
    
    -- 长按进度指示器 - 下键（属性面板）
    if state.downButtonHoldTime > state.longPressThreshold / 3 and not state.isPanelVisible() then
        local progress = state.downButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 220 + offsetY
        
        -- 绘制进度条
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按显示属性面板...", barX - 20, barY - 15)
    end
    
    -- 长按进度指示器 - B键（关闭面板）
    if state.bButtonHoldTime > state.longPressThreshold / 3 and state.isPanelVisible() then
        local progress = state.bButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2
        local barY = 120 + offsetY
        
        -- 绘制进度条
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按关闭面板...", barX - 10, barY - 15)
    end
    
    -- 面板状态提示
    if state.isSkillVisible() and state.screenOffset >= state.skillPanelHeight * 0.9 then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("↑/↓ 切换技能 - 长按B键关闭", 10, 100 + offsetY)
    elseif state.isAttributeVisible() and math.abs(state.screenOffset) >= state.attributePanelHeight * 0.9 then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("↑/↓ 切换选项 - 长按B键关闭", 10, 150 + offsetY)
    end
    
    -- 清除裁剪区域
    gfx.clearClipRect()
end

return mainArea
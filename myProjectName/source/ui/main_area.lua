-- ui/main_area.lua
local gfx <const> = playdate.graphics
local langMgr = LangMgr
local L
local function updateLang() L = langMgr.get() end

local mainArea = {}
function mainArea.draw(state)
    updateLang()
    
    -- 计算Y轴偏移（屏幕上移）
    local offsetY = -state.screenOffset
    
    -- 设置裁剪区域，防止内容绘制到属性面板区域
    local clipHeight = 240 - state.screenOffset
    gfx.setClipRect(0, 0, 400, clipHeight)
    
    -- 标题与提示（考虑偏移）
    gfx.drawText(L.ui.title, 10, 5 + offsetY)
    
    -- 添加分割线
    local separatorY = 20 + offsetY
    gfx.setColor(gfx.kColorBlack)
    gfx.drawLine(10, separatorY, 390, separatorY)
    
    gfx.drawText(L.ui.prompt, 10, 25 + offsetY)

    -- 显示当前选中的选项
    if L.menu and L.menu[state.selectedIndex] then
        local selectedOptionText = L.menu[state.selectedIndex]
        local y = 50 + offsetY
        
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
    
    -- 显示长按提示（只有在属性面板未显示时）
    if not state.isAttributeVisible() then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("长按 ↓ 键查看属性", 10, 200 + offsetY)
    end
        -- 长按进度指示器
    if state.downButtonHoldTime > 0 and not state.isAttributeVisible() then
        local progress = state.downButtonHoldTime / state.longPressThreshold
        if progress > 1 then progress = 1 end
        
        -- 绘制进度条背景
        local barWidth = 100
        local barHeight = 4
        local barX = (400 - barWidth) / 2  -- 居中
        local barY = 220 + offsetY
        
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        
        -- 绘制进度
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        -- 提示文字
        gfx.drawText("长按显示属性面板...", barX - 20, barY - 15)
    end

    -- 如果属性面板已显示，显示关闭提示
    if state.isAttributeVisible() and state.screenOffset >= state.attributePanelHeight * 0.9 then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("↑ 屏幕已上移 - 按A/B关闭", 10, 180 + offsetY)
    end
    -- 清除裁剪区域
    gfx.clearClipRect()
end

return mainArea
-- ui/main_area.lua - 主界面文本显示区域（支持滚动）

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics

-- 安全获取全局变量的函数
local function getLangMgr()
    return _G.LangMgr or LangMgr
end

local function getGameState()
    return _G.GameState or GameState
end

local L
local function updateLang() 
    local langMgr = getLangMgr()
    if langMgr then
        L = langMgr.get() 
    else
        L = { ui = { title = "Text Display" } }  -- 默认值
    end
end

-- ===== 主绘制函数区域 =====
local mainArea = {}

function mainArea.draw(state, textController)
    -- 安全检查参数
    if not state then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("Error: No state provided", 10, 10)
        return
    end
    
    updateLang()
    
    -- 从textController获取文本内容和滚动状态
    local textContent = textController and textController.getTextContent() or { title = "Text Display", content = {"No content"} }
    local scrollState = textController and textController.getScrollState() or { 
        scrollOffset = 0, 
        maxScrollOffset = 0,
        lineHeight = 18,            -- 更新为新的行高
        maxVisibleLines = 10,
        totalContentHeight = 0,
        visibleAreaHeight = 150
    }
    
    -- ===== 屏幕偏移计算区域 =====
    local offsetY = state.screenOffset or 0  -- 正值=下移，负值=上移
    
    -- --- 裁剪区域设置 ---
    local clipY = 0
    local clipHeight = 240
    local contentStartY = 45  -- 内容开始Y位置
    
    -- 安全检查 state 方法
    local isSkillVisible = (state.isSkillVisible and state.isSkillVisible()) or false
    local isAttributeVisible = (state.isAttributeVisible and state.isAttributeVisible()) or false
    local isPanelVisible = (state.isPanelVisible and state.isPanelVisible()) or false
    
    if isSkillVisible then
        clipY = state.screenOffset
        clipHeight = 240 - state.screenOffset
        contentStartY = 45 + state.screenOffset
    elseif isAttributeVisible then
        clipHeight = 240 + state.screenOffset  -- screenOffset为负值
    end
    
    gfx.setClipRect(0, clipY, 400, clipHeight)
    
    -- ===== 标题和导航区域 =====
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(textContent.title, 10, 5 + offsetY)
    
    -- --- 分割线 ---
    local separatorY = 20 + offsetY
    gfx.drawLine(10, separatorY, 390, separatorY)
    
    -- --- 滚动指示器 ---
    if scrollState.maxScrollOffset > 0 then
        local scrollPercent = scrollState.scrollOffset / scrollState.maxScrollOffset
        local currentLine = math.floor(scrollState.scrollOffset / scrollState.lineHeight) + 1
        local totalLines = #textContent.content
        local indicatorText = string.format("行: %d/%d (%d%%)", currentLine, totalLines, math.floor(scrollPercent * 100))
        gfx.drawText(indicatorText, 240, 5 + offsetY)
    else
        local totalLines = #textContent.content
        gfx.drawText("行: 1/" .. totalLines, 240, 5 + offsetY)
    end
    
    -- ===== 文本内容显示区域 =====
    local textAreaY = contentStartY
    local textAreaHeight = clipHeight - contentStartY - 10  -- 减少底部预留空间（原来是40）
    
    -- --- 文本内容绘制 ---
    gfx.setColor(gfx.kColorBlack)
    
    -- 计算第一个可见行的索引
    local firstVisibleLine = math.floor(scrollState.scrollOffset / scrollState.lineHeight) + 1
    local lastVisibleLine = math.min(firstVisibleLine + scrollState.maxVisibleLines + 1, #textContent.content)
    
    -- 绘制可见的文本行
    for i = firstVisibleLine, lastVisibleLine do
        local line = textContent.content[i]
        if line then
            local lineY = textAreaY + (i - 1) * scrollState.lineHeight - scrollState.scrollOffset
            
            -- 只绘制在可见区域内的行
            if lineY >= textAreaY - scrollState.lineHeight and lineY <= textAreaY + textAreaHeight then
                if line == "" then
                    -- 空行不绘制任何内容
                elseif string.sub(line, 1, 3) == "---" then
                    -- 分割线
                    gfx.drawLine(10, lineY + 8, 390, lineY + 8)
                elseif string.sub(line, 1, 1) == "•" then
                    -- 列表项，稍微缩进
                    gfx.drawText(line, 20, lineY)
                else
                    -- 普通文本
                    gfx.drawText(line, 10, lineY)
                end
            end
        end
    end
    
    -- ===== 滚动条绘制区域 =====
    if scrollState.maxScrollOffset > 0 then
        local scrollBarX = 390
        local scrollBarY = textAreaY
        local scrollBarHeight = textAreaHeight
        local scrollBarWidth = 3
        
        -- 滚动条背景
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(scrollBarX, scrollBarY, scrollBarWidth, scrollBarHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(scrollBarX, scrollBarY, scrollBarWidth, scrollBarHeight)
        
        -- 滚动条滑块
        local sliderHeight = math.max(10, scrollBarHeight * (scrollState.visibleAreaHeight / scrollState.totalContentHeight))
        local sliderY = scrollBarY + (scrollState.scrollOffset / scrollState.maxScrollOffset) * (scrollBarHeight - sliderHeight)
        
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(scrollBarX, sliderY, scrollBarWidth, sliderHeight)
    end
    
    -- ===== 长按进度指示器区域 =====
    local upButtonHoldTime = state.upButtonHoldTime or 0
    local downButtonHoldTime = state.downButtonHoldTime or 0
    local bButtonHoldTime = state.bButtonHoldTime or 0
    local longPressThreshold = state.longPressThreshold or 30
    
    -- --- 上键进度条（技能面板）---
    if upButtonHoldTime > longPressThreshold / 3 and not isPanelVisible then
        local progress = upButtonHoldTime / longPressThreshold
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
    if downButtonHoldTime > longPressThreshold / 3 and not isPanelVisible then
        local progress = downButtonHoldTime / longPressThreshold
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
    if bButtonHoldTime > longPressThreshold / 3 and isPanelVisible then
        local progress = bButtonHoldTime / longPressThreshold
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
    local skillPanelHeight = state.skillPanelHeight or 80
    local attributePanelHeight = state.attributePanelHeight or 70
    
    if isSkillVisible and state.screenOffset >= skillPanelHeight * 0.9 then
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.drawText("↑/↓ 切换技能 - 长按B键关闭", 10, 100 + offsetY)
    elseif isAttributeVisible and math.abs(state.screenOffset) >= attributePanelHeight * 0.9 then
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.drawText("↑/↓ 切换选项 - 长按B键关闭", 10, 150 + offsetY)
    end
    
    -- ===== 清理区域 =====
    gfx.clearClipRect()
end

-- ===== 兼容性接口（现在通过textController处理） =====
function mainArea.scrollUp()
    -- 这些函数现在由textController处理
    print("提示：滚动功能已移至textController")
end

function mainArea.scrollDown()
    print("提示：滚动功能已移至textController")
end

function mainArea.setContent(title, content)
    print("提示：内容设置功能已移至textController")
end

function mainArea.getScrollState()
    print("提示：滚动状态获取功能已移至textController")
    return { canScrollUp = false, canScrollDown = false, scrollPercent = 0 }
end

return mainArea
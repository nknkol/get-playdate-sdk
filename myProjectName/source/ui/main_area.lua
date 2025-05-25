-- ui/main_area.lua - 主界面文本显示区域（统一窗口动画）

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
        lineHeight = 18,
        maxVisibleLines = 10,
        totalContentHeight = 0,
        visibleAreaHeight = 150
    }
    
    -- ===== 统一窗口偏移计算区域 =====
    -- 只有技能面板显示时才推动主页，属性面板是覆盖效果
    local windowOffsetY = 0
    if isSkillVisible then
        windowOffsetY = state.screenOffset  -- 技能面板：推动主页
    else
        windowOffsetY = 0  -- 属性面板：不推动主页，保持覆盖效果
    end
    
    -- --- 裁剪区域设置 ---
    local clipY = 0
    local clipHeight = 240
    
    -- 安全检查 state 方法
    local isSkillVisible = (state.isSkillVisible and state.isSkillVisible()) or false
    local isAttributeVisible = (state.isAttributeVisible and state.isAttributeVisible()) or false
    local isPanelVisible = (state.isPanelVisible and state.isPanelVisible()) or false
    
    if isSkillVisible then
        -- 技能面板显示时，裁剪区域从技能面板底部开始（推动效果）
        clipY = state.screenOffset
        clipHeight = 240 - state.screenOffset
    elseif isAttributeVisible then
        -- 属性面板显示时，保持原有裁剪区域（覆盖效果，不推动主页）
        clipY = 0
        clipHeight = 240
    end
    
    gfx.setClipRect(0, clipY, 400, clipHeight)
    
    -- ===== 统一窗口内容区域（所有元素使用相同的基础偏移） =====
    local baseY = windowOffsetY  -- 窗口基础偏移
    
    -- --- 标题区域 ---
    gfx.setColor(gfx.kColorBlack)
    local titleY = baseY + 5
    gfx.drawText(textContent.title, 10, titleY)
    
    -- --- 分割线 ---
    local separatorY = baseY + 20
    gfx.drawLine(10, separatorY, 390, separatorY)
    
    -- --- 滚动指示器 ---
    if scrollState.maxScrollOffset > 0 then
        local scrollPercent = scrollState.scrollOffset / scrollState.maxScrollOffset
        local currentLine = math.floor(scrollState.scrollOffset / scrollState.lineHeight) + 1
        local totalLines = #textContent.content
        local indicatorText = string.format("行: %d/%d (%d%%)", currentLine, totalLines, math.floor(scrollPercent * 100))
        gfx.drawText(indicatorText, 240, titleY)
    else
        local totalLines = #textContent.content
        gfx.drawText("行: 1/" .. totalLines, 240, titleY)
    end
    
    -- ===== 文本内容显示区域 =====
    local textAreaStartY = baseY + 45  -- 文本区域开始位置（与窗口其他元素保持一致的偏移）
    
    -- 计算文本区域的实际可用高度
    local textAreaHeight
    if isSkillVisible then
        -- 技能面板模式：可用高度 = 裁剪区域底部 - 文本区域开始位置 - 底部预留
        textAreaHeight = (clipY + clipHeight) - textAreaStartY - 10
    else
        -- 正常模式和属性面板模式：属性面板是覆盖效果，不影响主页文本区域
        textAreaHeight = 240 - textAreaStartY - 10
    end
    
    -- 确保文本区域高度为正值
    if textAreaHeight < 0 then
        textAreaHeight = 0
    end
    
    -- --- 文本内容绘制 ---
    gfx.setColor(gfx.kColorBlack)
    
    -- 计算第一个可见行的索引
    local firstVisibleLine = math.floor(scrollState.scrollOffset / scrollState.lineHeight) + 1
    local lastVisibleLine = math.min(firstVisibleLine + scrollState.maxVisibleLines + 1, #textContent.content)
    
    -- 绘制可见的文本行
    for i = firstVisibleLine, lastVisibleLine do
        local line = textContent.content[i]
        if line then
            -- 文本行的Y位置 = 文本区域开始位置 + 行偏移 - 滚动偏移
            local lineY = textAreaStartY + (i - 1) * scrollState.lineHeight - scrollState.scrollOffset
            
            -- 只绘制在可见区域内的行
            if lineY >= textAreaStartY - scrollState.lineHeight and lineY <= textAreaStartY + textAreaHeight then
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
    if scrollState.maxScrollOffset > 0 and textAreaHeight > 0 then
        local scrollBarX = 390
        local scrollBarY = textAreaStartY
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
    
    -- ===== 长按进度指示器区域（也使用统一的窗口偏移） =====
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
        local barY = baseY + 30
        
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
        local barY = baseY + 220
        
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
        local barY = baseY + 120
        
        -- 进度条绘制
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barWidth * progress, barHeight)
        
        gfx.drawText("长按关闭面板...", barX - 10, barY - 15)
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
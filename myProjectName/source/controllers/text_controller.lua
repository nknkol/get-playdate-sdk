-- controllers/text_controller.lua - 文本滚动控制器

-- ===== 依赖导入区域 =====
-- 注意：在 Playdate 中，所有 import 必须在文件加载时完成，不能延迟导入

local textController = {}

-- ===== 文本滚动控制区域 =====
function textController.update()
    -- 安全获取全局状态
    local gameState = _G.GameState or GameState
    if not gameState then
        return  -- 安全退出
    end
    
    -- ===== 下键输入处理区域（滚动/属性面板） =====
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        gameState.downButtonHoldTime = (gameState.downButtonHoldTime or 0) + 1
        
        -- --- 长按触发属性面板 ---
        local threshold = gameState.longPressThreshold or 30
        if gameState.downButtonHoldTime == threshold then
            local isAttributeVisible = gameState.isAttributeVisible and gameState.isAttributeVisible()
            if isAttributeVisible then
                if gameState.hideAttributePanel then
                    gameState.hideAttributePanel()
                end
            else
                local isSkillVisible = gameState.isSkillVisible and gameState.isSkillVisible()
                if isSkillVisible and gameState.hideSkillPanel then
                    gameState.hideSkillPanel()
                end
                if gameState.showAttributePanel then
                    gameState.showAttributePanel()
                end
            end
        end
    else
        -- --- 下键释放处理 ---
        local holdTime = gameState.downButtonHoldTime or 0
        if holdTime > 0 then
            local threshold = gameState.longPressThreshold or 30
            if holdTime < threshold then
                -- 短按：向下滚动文本
                local isPanelVisible = gameState.isPanelVisible and gameState.isPanelVisible()
                if not isPanelVisible then
                    -- 直接调用滚动函数，避免通过mainArea
                    textController.scrollDown()
                end
            end
            gameState.downButtonHoldTime = 0
        end
    end
    
    -- ===== 上键输入处理区域（滚动/技能面板） =====
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        gameState.upButtonHoldTime = (gameState.upButtonHoldTime or 0) + 1
        
        -- --- 长按触发技能面板 ---
        local threshold = gameState.longPressThreshold or 30
        if gameState.upButtonHoldTime == threshold then
            local isSkillVisible = gameState.isSkillVisible and gameState.isSkillVisible()
            if isSkillVisible then
                if gameState.hideSkillPanel then
                    gameState.hideSkillPanel()
                end
            else
                local isAttributeVisible = gameState.isAttributeVisible and gameState.isAttributeVisible()
                if isAttributeVisible and gameState.hideAttributePanel then
                    gameState.hideAttributePanel()
                end
                if gameState.showSkillPanel then
                    gameState.showSkillPanel()
                end
            end
        end
    else
        -- --- 上键释放处理 ---
        local holdTime = gameState.upButtonHoldTime or 0
        if holdTime > 0 then
            local threshold = gameState.longPressThreshold or 30
            if holdTime < threshold then
                -- 短按：向上滚动文本
                local isPanelVisible = gameState.isPanelVisible and gameState.isPanelVisible()
                if not isPanelVisible then
                    -- 直接调用滚动函数，避免通过mainArea
                    textController.scrollUp()
                end
            end
            gameState.upButtonHoldTime = 0
        end
    end
    
    -- ===== A键功能处理区域（快速跳转） =====
    if playdate.buttonJustPressed(playdate.kButtonA) then
        -- 在文本模式下，A键用于快速跳转
        local scrollInfo = textController.getScrollInfo()
        if scrollInfo.scrollPercent > 0.5 then
            -- 如果滚动超过一半，跳转到顶部
            textController.scrollToTop()
        else
            -- 否则跳转到底部
            textController.scrollToBottom()
        end
    end
    
    -- ===== B键输入处理区域（返回/关闭） =====
    if playdate.buttonIsPressed(playdate.kButtonB) then
        gameState.bButtonHoldTime = (gameState.bButtonHoldTime or 0) + 1
        
        -- --- 长按触发关闭面板 ---
        local threshold = gameState.longPressThreshold or 30
        if gameState.bButtonHoldTime == threshold then
            local isPanelVisible = gameState.isPanelVisible and gameState.isPanelVisible()
            if isPanelVisible and gameState.hideAllPanels then
                gameState.hideAllPanels()
                print("长按B键关闭面板")
            end
        end
    else
        -- --- B键释放处理 ---
        local holdTime = gameState.bButtonHoldTime or 0
        if holdTime > 0 then
            local threshold = gameState.longPressThreshold or 30
            if holdTime < threshold then
                -- 短按B键：切换模式或其他功能
                local isPanelVisible = gameState.isPanelVisible and gameState.isPanelVisible()
                if isPanelVisible then
                    print("有面板显示时短按B键无效果，请长按关闭面板")
                -- else
                --     -- gameState.currentMode = "panel_switch"
                --     -- -- print("切换到面板切换模式")
                end
            end
            gameState.bButtonHoldTime = 0
        end
    end
    
    -- ===== 摇杆输入处理区域（可选的额外滚动控制） =====
    local crankChange = playdate.getCrankChange()
    if math.abs(crankChange) > 1 then
        local gameState = _G.GameState or GameState
        if gameState then
            local isPanelVisible = gameState.isPanelVisible and gameState.isPanelVisible()
            if not isPanelVisible then
                -- 使用摇杆进行精细滚动控制
                if crankChange > 0 then
                    textController.scrollDown()
                elseif crankChange < 0 then
                    textController.scrollUp()
                end
            end
        end
    end
end

-- ===== 内部滚动状态管理 =====
-- 将滚动状态移到控制器内部，避免依赖mainArea
local scrollState = {
    scrollOffset = 0,           -- 当前滚动偏移量（正值=向上滚动）
    targetScrollOffset = 0,     -- 目标滚动偏移量
    scrollSpeed = 3,            -- 滚动动画速度（降低以获得更快响应）
    lineHeight = 18,            -- 行高（增加以获得更明显的滚动）
    maxVisibleLines = 0,        -- 可见行数（动态计算）
    totalContentHeight = 0,     -- 内容总高度
    visibleAreaHeight = 0,      -- 可见区域高度
    maxScrollOffset = 0,        -- 最大滚动偏移量
}

-- 文本内容存储
local textContent = {
    title = "冒险日志",
    content = {
        "欢迎来到地下城探险！",
        "",
        "这是一个文本滚动显示的示例。"
    }
}

-- ===== 滚动工具函数 =====
local function calculateContentDimensions(visibleHeight)
    scrollState.visibleAreaHeight = visibleHeight or 150
    scrollState.maxVisibleLines = math.floor(scrollState.visibleAreaHeight / scrollState.lineHeight)
    scrollState.totalContentHeight = #textContent.content * scrollState.lineHeight
    
    -- 计算最大滚动偏移量，确保最后一行能完全显示
    scrollState.maxScrollOffset = math.max(0, scrollState.totalContentHeight - scrollState.visibleAreaHeight)
    
    -- 调试信息
    -- print("内容高度: " .. scrollState.totalContentHeight .. ", 可见高度: " .. scrollState.visibleAreaHeight .. ", 最大滚动: " .. scrollState.maxScrollOffset)
end

local function updateScrollAnimation()
    -- 平滑滚动动画，但响应更快
    if math.abs(scrollState.scrollOffset - scrollState.targetScrollOffset) > 0.5 then
        scrollState.scrollOffset += (scrollState.targetScrollOffset - scrollState.scrollOffset) / scrollState.scrollSpeed
    else
        scrollState.scrollOffset = scrollState.targetScrollOffset
    end
end

local function scrollText(delta)
    -- 更新目标滚动位置
    local newOffset = scrollState.targetScrollOffset + (delta * scrollState.lineHeight)
    
    -- 限制滚动范围
    if newOffset < 0 then
        newOffset = 0
    elseif newOffset > scrollState.maxScrollOffset then
        newOffset = scrollState.maxScrollOffset
    end
    
    -- 只有在边界内才更新目标位置
    if newOffset ~= scrollState.targetScrollOffset then
        scrollState.targetScrollOffset = newOffset
        print("滚动到: " .. math.floor(newOffset) .. "/" .. math.floor(scrollState.maxScrollOffset))
    end
end

-- ===== 文本控制接口 =====
function textController.scrollUp()
    calculateContentDimensions()  -- 确保尺寸是最新的
    local oldOffset = scrollState.targetScrollOffset
    scrollText(-1)  -- 向上滚动一行
    
    -- 检查是否真的滚动了
    if scrollState.targetScrollOffset == oldOffset then
        print("已到达顶部")
    else
        print("向上滚动一行")
    end
end

function textController.scrollDown()
    calculateContentDimensions()  -- 确保尺寸是最新的
    local oldOffset = scrollState.targetScrollOffset
    scrollText(1)   -- 向下滚动一行
    
    -- 检查是否真的滚动了
    if scrollState.targetScrollOffset == oldOffset then
        print("已到达底部")
    else
        print("向下滚动一行")
    end
end

-- 立即滚动（无动画）
function textController.scrollUpImmediate()
    calculateContentDimensions()
    scrollText(-1)
    scrollState.scrollOffset = scrollState.targetScrollOffset  -- 立即跳转
    print("立即向上滚动")
end

function textController.scrollDownImmediate()
    calculateContentDimensions()
    scrollText(1)
    scrollState.scrollOffset = scrollState.targetScrollOffset  -- 立即跳转
    print("立即向下滚动")
end

-- 滚动到顶部
function textController.scrollToTop()
    scrollState.targetScrollOffset = 0
    scrollState.scrollOffset = 0  -- 立即跳转
    print("跳转到顶部")
end

-- 滚动到底部
function textController.scrollToBottom()
    calculateContentDimensions()
    scrollState.targetScrollOffset = scrollState.maxScrollOffset
    scrollState.scrollOffset = scrollState.maxScrollOffset  -- 立即跳转
    print("跳转到底部")
end

function textController.setContent(title, content)
    textContent.title = title or textContent.title
    textContent.content = content or textContent.content
    
    -- 重置滚动位置
    scrollState.scrollOffset = 0
    scrollState.targetScrollOffset = 0
    
    -- 重新计算内容尺寸
    calculateContentDimensions()
end

function textController.getScrollInfo()
    updateScrollAnimation()  -- 更新动画状态
    return {
        canScrollUp = scrollState.targetScrollOffset > 0,
        canScrollDown = scrollState.targetScrollOffset < scrollState.maxScrollOffset,
        scrollPercent = scrollState.maxScrollOffset > 0 and (scrollState.scrollOffset / scrollState.maxScrollOffset) or 0
    }
end

-- ===== 获取滚动状态供外部使用 =====
function textController.getScrollState()
    return scrollState
end

function textController.getTextContent()
    return textContent
end

-- ===== 更新滚动动画（供主循环调用） =====
function textController.updateAnimation()
    updateScrollAnimation()
end

return textController
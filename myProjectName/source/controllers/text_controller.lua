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
    
    -- ===== A键功能处理区域（可自定义） =====
    if playdate.buttonJustPressed(playdate.kButtonA) then
        -- 在文本模式下，A键可以用作其他功能
        -- 例如：快速滚动到顶部或底部
        local scrollState = textController.getScrollInfo()
        if scrollState.scrollPercent > 0.5 then
            -- 如果滚动超过一半，跳转到顶部
            textController.setContent(nil, nil)  -- 重置滚动位置
            print("跳转到文本顶部")
        else
            -- 否则跳转到底部
            for i = 1, 50 do  -- 滚动足够多次到达底部
                textController.scrollDown()
            end
            print("跳转到文本底部")
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
                else
                    gameState.currentMode = "panel_switch"
                    print("切换到面板切换模式")
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
    scrollSpeed = 4,            -- 滚动动画速度
    lineHeight = 16,            -- 行高
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
end

local function updateScrollAnimation()
    -- 平滑滚动动画
    if math.abs(scrollState.scrollOffset - scrollState.targetScrollOffset) > 1 then
        scrollState.scrollOffset += (scrollState.targetScrollOffset - scrollState.scrollOffset) / scrollState.scrollSpeed
    else
        scrollState.scrollOffset = scrollState.targetScrollOffset
    end
end

local function scrollText(delta)
    -- 更新目标滚动位置
    scrollState.targetScrollOffset += delta * scrollState.lineHeight
    
    -- 限制滚动范围
    if scrollState.targetScrollOffset < 0 then
        scrollState.targetScrollOffset = 0
    elseif scrollState.targetScrollOffset > scrollState.maxScrollOffset then
        scrollState.targetScrollOffset = scrollState.maxScrollOffset
    end
end

-- ===== 文本控制接口 =====
function textController.scrollUp()
    calculateContentDimensions()  -- 确保尺寸是最新的
    scrollText(-1)  -- 向上滚动一行
end

function textController.scrollDown()
    calculateContentDimensions()  -- 确保尺寸是最新的
    scrollText(1)   -- 向下滚动一行
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
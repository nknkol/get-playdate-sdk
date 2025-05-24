-- source/data/game_state.lua
local state = {
    currentMode   = "main_sentence",
    selectedIndex = 1,
    showStatus    = true,
    showAttribute = false,
    
    -- 新增：屏幕滑动相关
    screenOffset = 0,           -- 当前屏幕Y偏移量
    targetOffset = 0,           -- 目标偏移量
    attributePanelHeight = 70,  -- 属性面板高度
    animationSpeed = 8,         -- 动画速度
    
    -- 长按检测
    downButtonHoldTime = 0,     -- 下键按住时间
    longPressThreshold = 30     -- 长按阈值（帧数，约0.5秒）
}

-- 工具函数
function state.isAttributeVisible()
    return state.targetOffset > 0
end

function state.showAttributePanel()
    state.targetOffset = state.attributePanelHeight
    state.showAttribute = true
end

function state.hideAttributePanel()
    state.targetOffset = 0
    state.showAttribute = false
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
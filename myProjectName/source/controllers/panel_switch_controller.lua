-- =====================================================
-- controllers/panel_switch_controller.lua - 面板切换控制器
-- =====================================================

-- ===== 依赖导入区域 =====
-- 安全获取全局状态
local function getGameState()
    return _G.GameState or GameState
end

-- ===== 面板切换逻辑区域 =====
local panelController = {}

function panelController.update()
    local gameState = getGameState()
    if not gameState then return end
    
    -- --- 下键：显示属性面板 ---
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        gameState.showStatus = false
        gameState.showAttribute = true
        -- 返回文本模式而不是main_sentence模式
        gameState.currentMode = "text_mode"
    
    -- --- 上键：显示状态面板 ---
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        gameState.showStatus = true
        gameState.showAttribute = false
        -- 返回文本模式而不是main_sentence模式
        gameState.currentMode = "text_mode"
        
    -- --- B键：返回文本模式 ---
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        gameState.currentMode = "text_mode"
        print("返回文本模式")
    end
end

return panelController
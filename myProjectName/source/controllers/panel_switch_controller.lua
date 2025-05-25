-- =====================================================
-- controllers/panel_switch_controller.lua - 面板切换控制器
-- =====================================================

-- ===== 依赖导入区域 =====
local gameState = GameState

-- ===== 面板切换逻辑区域 =====
local panelController = {}
function panelController.update()
    -- --- 下键：显示属性面板 ---
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        gameState.showStatus = false
        gameState.showAttribute = true
        gameState.currentMode = "main_sentence"
    
    -- --- 上键：显示状态面板 ---
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        gameState.showStatus = true
        gameState.showAttribute = false
        gameState.currentMode = "main_sentence"
    end
end
return panelController
-- =====================================================
-- controllers/controller.lua - 总控制器分发器
-- =====================================================

-- ===== 依赖导入区域 =====
local gameState = GameState
local mainSentence = import "controllers/main_sentence_controller"
local panelSwitch = import "controllers/panel_switch_controller"

-- ===== 控制器分发区域 =====
local controller = {}
function controller.update()
    -- --- 根据当前模式调用对应控制器 ---
    if gameState.currentMode == "main_sentence" then
        mainSentence.update()
    elseif gameState.currentMode == "panel_switch" then
        panelSwitch.update()
    end
end
return controller
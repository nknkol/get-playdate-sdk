-- =====================================================
-- controllers/controller.lua - 总控制器分发器（更新版）
-- =====================================================

-- ===== 依赖导入区域 =====
-- 在 Playdate 中，所有 import 必须在文件加载时完成
local textController = import "controllers/text_controller"        -- 文本滚动控制器
local mainSentence = import "controllers/main_sentence_controller"   -- 原菜单控制器  
local panelSwitch = import "controllers/panel_switch_controller"     -- 面板切换控制器

-- 安全获取全局状态
local function getGameState()
    return _G.GameState or GameState
end

-- ===== 控制器分发区域 =====
local controller = {}

function controller.update()
    local gameState = getGameState()
    if not gameState then return end
    
    -- --- 根据当前模式调用对应控制器 ---
    local currentMode = gameState.currentMode or "text_mode"
    
    if currentMode == "text_mode" then
        -- 文本滚动模式
        if textController and textController.update then
            textController.update()
        end
        -- 更新文本滚动动画
        if textController and textController.updateAnimation then
            textController.updateAnimation()
        end
    elseif currentMode == "main_sentence" then
        -- 原菜单导航模式
        if mainSentence and mainSentence.update then
            mainSentence.update()
        end
    elseif currentMode == "panel_switch" then
        -- 面板切换模式
        if panelSwitch and panelSwitch.update then
            panelSwitch.update()
        end
    end
end

-- ===== 模式切换接口 =====
function controller.switchToTextMode()
    local gameState = getGameState()
    if gameState then
        gameState.currentMode = "text_mode"
        print("切换到文本滚动模式")
    end
end

function controller.switchToMenuMode()
    local gameState = getGameState()
    if gameState then
        gameState.currentMode = "main_sentence"
        print("切换到菜单导航模式")
    end
end

function controller.switchToPanelMode()
    local gameState = getGameState()
    if gameState then
        gameState.currentMode = "panel_switch"
        print("切换到面板切换模式")
    end
end

function controller.getCurrentMode()
    local gameState = getGameState()
    return gameState and gameState.currentMode or "text_mode"
end

-- ===== 文本内容管理接口 =====
function controller.setTextContent(title, content)
    if textController and textController.setContent then
        textController.setContent(title, content)
    end
end

function controller.getScrollInfo()
    if textController and textController.getScrollInfo then
        return textController.getScrollInfo()
    end
    return { canScrollUp = false, canScrollDown = false, scrollPercent = 0 }
end

-- ===== 获取textController引用 =====
function controller.getTextController()
    return textController
end

return controller
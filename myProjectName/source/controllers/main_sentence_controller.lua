-- controllers/main_sentence_controller.lua
local gameState = GameState
local l = LangMgr.get()

local mainController = {}
function mainController.update()
    -- 更新语言（防止运行时切换语言）
    l = LangMgr.get()
    
    -- 长按下键检测
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        gameState.downButtonHoldTime += 1
        
        -- 达到长按阈值时触发属性面板
        if gameState.downButtonHoldTime == gameState.longPressThreshold then
            if gameState.isAttributeVisible() then
                gameState.hideAttributePanel()
            else
                gameState.showAttributePanel()
            end
        end
    else
        -- 释放下键时的处理
        if gameState.downButtonHoldTime > 0 then
            -- 如果是短按（未达到长按阈值）且属性面板未显示，则正常切换菜单
            if gameState.downButtonHoldTime < gameState.longPressThreshold and not gameState.isAttributeVisible() then
                gameState.selectedIndex += 1
                if gameState.selectedIndex > #l.menu then
                    gameState.selectedIndex = 1
                end
            end
            gameState.downButtonHoldTime = 0
        end
    end
    
    -- 上键处理（只有在属性面板未显示时才响应）
    if playdate.buttonJustPressed(playdate.kButtonUp) and not gameState.isAttributeVisible() then
        gameState.selectedIndex -= 1
        if gameState.selectedIndex < 1 then
            gameState.selectedIndex = #l.menu
        end
    end
    
    -- A键确认选择
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if gameState.isAttributeVisible() then
            -- 属性面板显示时，A键隐藏面板
            gameState.hideAttributePanel()
        else
            -- 执行选中的动作
            local selectedAction = l.menu[gameState.selectedIndex]
            print("执行动作: " .. selectedAction)
            -- 这里可以添加具体的动作处理逻辑
        end
    end
    
    -- B键处理
    if playdate.buttonJustPressed(playdate.kButtonB) then
        if gameState.isAttributeVisible() then
            -- 属性面板显示时，B键隐藏面板
            gameState.hideAttributePanel()
        else
            -- 进入面板切换模式
            gameState.currentMode = "panel_switch"
        end
    end
end

return mainController
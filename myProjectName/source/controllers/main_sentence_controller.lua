-- controllers/main_sentence_controller.lua
local gameState = GameState
local l = LangMgr.get()

local mainController = {}
function mainController.update()
    -- 更新语言（防止运行时切换语言）
    l = LangMgr.get()
    
    -- 长按下键检测（属性面板）
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        gameState.downButtonHoldTime += 1
        
        -- 达到长按阈值时触发属性面板
        if gameState.downButtonHoldTime == gameState.longPressThreshold then
            if gameState.isAttributeVisible() then
                gameState.hideAttributePanel()
            else
                -- 如果技能面板正在显示，先关闭它
                if gameState.isSkillVisible() then
                    gameState.hideSkillPanel()
                end
                gameState.showAttributePanel()
            end
        end
    else
        -- 释放下键时的处理
        if gameState.downButtonHoldTime > 0 then
            -- 如果是短按（未达到长按阈值）且没有面板显示，则正常切换菜单
            if gameState.downButtonHoldTime < gameState.longPressThreshold and not gameState.isPanelVisible() then
                gameState.selectedIndex += 1
                if gameState.selectedIndex > #l.menu then
                    gameState.selectedIndex = 1
                end
            end
            gameState.downButtonHoldTime = 0
        end
    end
    
    -- 长按上键检测（技能面板）- 新增
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        gameState.upButtonHoldTime += 1
        
        -- 达到长按阈值时触发技能面板
        if gameState.upButtonHoldTime == gameState.longPressThreshold then
            if gameState.isSkillVisible() then
                gameState.hideSkillPanel()
            else
                -- 如果属性面板正在显示，先关闭它
                if gameState.isAttributeVisible() then
                    gameState.hideAttributePanel()
                end
                gameState.showSkillPanel()
            end
        end
    else
        -- 释放上键时的处理
        if gameState.upButtonHoldTime > 0 then
            -- 如果是短按（未达到长按阈值）且没有面板显示，则正常切换菜单
            if gameState.upButtonHoldTime < gameState.longPressThreshold and not gameState.isPanelVisible() then
                gameState.selectedIndex -= 1
                if gameState.selectedIndex < 1 then
                    gameState.selectedIndex = #l.menu
                end
            end
            gameState.upButtonHoldTime = 0
        end
    end
    
    -- A键确认选择
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if gameState.isPanelVisible() then
            -- 有面板显示时，A键关闭所有面板
            gameState.hideAllPanels()
        else
            -- 执行选中的动作
            local selectedAction = l.menu[gameState.selectedIndex]
            print("执行动作: " .. selectedAction)
            -- 这里可以添加具体的动作处理逻辑
        end
    end
    
    -- B键处理
    if playdate.buttonJustPressed(playdate.kButtonB) then
        if gameState.isPanelVisible() then
            -- 有面板显示时，B键关闭所有面板
            gameState.hideAllPanels()
        else
            -- 进入面板切换模式
            gameState.currentMode = "panel_switch"
        end
    end
end

return mainController
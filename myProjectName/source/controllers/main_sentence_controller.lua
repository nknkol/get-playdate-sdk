-- controllers/main_sentence_controller.lua
local gameState = GameState
local l = LangMgr.get()

local mainController = {}

-- 获取当前菜单数据
local function getCurrentMenu()
    l = LangMgr.get()  -- 更新语言
    
    if gameState.currentMenuId == "main" then
        return l.menu  -- 主菜单
    elseif gameState.currentMenuData then
        return gameState.currentMenuData  -- 自定义菜单数据
    else
        return l.menu  -- 默认返回主菜单
    end
end

-- 处理菜单选择逻辑
local function handleMenuSelection(selectedAction, selectedIndex)
    -- 这里可以根据不同的菜单和选项执行不同的逻辑
    if gameState.currentMenuId == "main" then
        -- 主菜单逻辑
        if selectedAction == "攻击" or selectedAction == "Attack" then
            -- 进入攻击目标选择子菜单
            local enemyTargets = {"哥布林", "骷髅兵", "魔法师"}
            gameState.pushMenu("attack_target", enemyTargets)
            print("进入攻击目标选择")
        elseif selectedAction == "嘲讽" or selectedAction == "Taunt" then
            -- 嘲讽直接执行，无子菜单
            print("执行嘲讽")
        elseif selectedAction == "撤退" or selectedAction == "Flee" then
            -- 撤退确认子菜单
            local confirmOptions = {"确认撤退", "取消"}
            gameState.pushMenu("flee_confirm", confirmOptions)
            print("进入撤退确认菜单")
        end
    elseif gameState.currentMenuId == "attack_target" then
        -- 攻击目标选择
        print("攻击目标: " .. selectedAction)
        -- 执行攻击后返回主菜单
        gameState.clearMenuStack()
    elseif gameState.currentMenuId == "flee_confirm" then
        -- 撤退确认
        if selectedIndex == 1 then
            print("确认撤退")
            gameState.clearMenuStack()
        else
            print("取消撤退")
            gameState.popMenu()  -- 返回主菜单
        end
    else
        -- 其他自定义菜单的处理
        print("执行动作: " .. selectedAction)
    end
end

function mainController.update()
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
            -- 如果是短按（未达到长按阈值），则正常切换菜单
            if gameState.downButtonHoldTime < gameState.longPressThreshold then
                local currentMenu = getCurrentMenu()
                if currentMenu then
                    gameState.selectedIndex += 1
                    if gameState.selectedIndex > #currentMenu then
                        gameState.selectedIndex = 1
                    end
                end
            end
            gameState.downButtonHoldTime = 0
        end
    end
    
    -- 长按上键检测（技能面板）
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
            -- 如果是短按（未达到长按阈值），则正常切换菜单
            if gameState.upButtonHoldTime < gameState.longPressThreshold then
                local currentMenu = getCurrentMenu()
                if currentMenu then
                    gameState.selectedIndex -= 1
                    if gameState.selectedIndex < 1 then
                        gameState.selectedIndex = #currentMenu
                    end
                end
            end
            gameState.upButtonHoldTime = 0
        end
    end
    
    -- A键确认选择
    if playdate.buttonJustPressed(playdate.kButtonA) then
        local currentMenu = getCurrentMenu()
        if currentMenu and currentMenu[gameState.selectedIndex] then
            local selectedAction = currentMenu[gameState.selectedIndex]
            handleMenuSelection(selectedAction, gameState.selectedIndex)
        end
    end
    
    -- B键长按检测（新的逻辑）
    if playdate.buttonIsPressed(playdate.kButtonB) then
        gameState.bButtonHoldTime += 1
        
        -- 达到长按阈值时关闭扩展面板
        if gameState.bButtonHoldTime == gameState.longPressThreshold then
            if gameState.isPanelVisible() then
                gameState.hideAllPanels()
                print("长按B键关闭面板")
            end
        end
    else
        -- 释放B键时的处理
        if gameState.bButtonHoldTime > 0 then
            -- 如果是短按（未达到长按阈值），执行返回逻辑
            if gameState.bButtonHoldTime < gameState.longPressThreshold then
                -- 短按B键：返回逻辑
                if gameState.isPanelVisible() then
                    -- 如果有面板显示，短按B键不做任何事情（需要长按才能关闭面板）
                    print("有面板显示时短按B键无效果，请长按关闭面板")
                elseif gameState.isInSubMenu() then
                    -- 在子菜单中，短按B键返回上一级
                    gameState.popMenu()
                    print("返回上一级菜单")
                else
                    -- 在主菜单中，短按B键可以执行其他逻辑（如进入设置等）
                    gameState.currentMode = "panel_switch"  -- 保持原有逻辑
                    print("进入面板切换模式")
                end
            end
            gameState.bButtonHoldTime = 0
        end
    end
end

return mainController
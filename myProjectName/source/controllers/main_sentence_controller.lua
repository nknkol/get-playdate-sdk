-- controllers/main_sentence_controller.lua - 主要输入控制器

-- ===== 依赖导入区域 =====
local gameState = GameState
local l = LangMgr.get()

local mainController = {}

-- ===== 菜单数据获取区域 =====
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

-- ===== 菜单选择逻辑处理区域 =====
local function handleMenuSelection(selectedAction, selectedIndex)
    -- --- 主菜单处理 ---
    if gameState.currentMenuId == "main" then
        if selectedAction == "攻击" or selectedAction == "Attack" then
            local enemyTargets = {"哥布林", "骷髅兵", "魔法师"}
            gameState.pushMenu("attack_target", enemyTargets)
            print("进入攻击目标选择")
        elseif selectedAction == "嘲讽" or selectedAction == "Taunt" then
            print("执行嘲讽")
        elseif selectedAction == "撤退" or selectedAction == "Flee" then
            local confirmOptions = {"确认撤退", "取消"}
            gameState.pushMenu("flee_confirm", confirmOptions)
            print("进入撤退确认菜单")
        end
    
    -- --- 攻击目标菜单处理 ---
    elseif gameState.currentMenuId == "attack_target" then
        print("攻击目标: " .. selectedAction)
        gameState.clearMenuStack()
    
    -- --- 撤退确认菜单处理 ---
    elseif gameState.currentMenuId == "flee_confirm" then
        if selectedIndex == 1 then
            print("确认撤退")
            gameState.clearMenuStack()
        else
            print("取消撤退")
            gameState.popMenu()
        end
    
    -- --- 其他自定义菜单处理 ---
    else
        print("执行动作: " .. selectedAction)
    end
end

-- ===== 主要输入更新循环区域 =====
function mainController.update()
    
    -- ===== 下键输入处理区域（属性面板） =====
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        gameState.downButtonHoldTime += 1
        
        -- --- 长按触发属性面板 ---
        if gameState.downButtonHoldTime == gameState.longPressThreshold then
            if gameState.isAttributeVisible() then
                gameState.hideAttributePanel()
            else
                if gameState.isSkillVisible() then
                    gameState.hideSkillPanel()
                end
                gameState.showAttributePanel()
            end
        end
    else
        -- --- 下键释放处理 ---
        if gameState.downButtonHoldTime > 0 then
            if gameState.downButtonHoldTime < gameState.longPressThreshold then
                -- 短按：菜单向下选择
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
    
    -- ===== 上键输入处理区域（技能面板） =====
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        gameState.upButtonHoldTime += 1
        
        -- --- 长按触发技能面板 ---
        if gameState.upButtonHoldTime == gameState.longPressThreshold then
            if gameState.isSkillVisible() then
                gameState.hideSkillPanel()
            else
                if gameState.isAttributeVisible() then
                    gameState.hideAttributePanel()
                end
                gameState.showSkillPanel()
            end
        end
    else
        -- --- 上键释放处理 ---
        if gameState.upButtonHoldTime > 0 then
            if gameState.upButtonHoldTime < gameState.longPressThreshold then
                -- 短按：菜单向上选择
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
    
    -- ===== A键确认处理区域 =====
    if playdate.buttonJustPressed(playdate.kButtonA) then
        local currentMenu = getCurrentMenu()
        if currentMenu and currentMenu[gameState.selectedIndex] then
            local selectedAction = currentMenu[gameState.selectedIndex]
            handleMenuSelection(selectedAction, gameState.selectedIndex)
        end
    end
    
    -- ===== B键输入处理区域（返回/关闭） =====
    if playdate.buttonIsPressed(playdate.kButtonB) then
        gameState.bButtonHoldTime += 1
        
        -- --- 长按触发关闭面板 ---
        if gameState.bButtonHoldTime == gameState.longPressThreshold then
            if gameState.isPanelVisible() then
                gameState.hideAllPanels()
                print("长按B键关闭面板")
            end
        end
    else
        -- --- B键释放处理 ---
        if gameState.bButtonHoldTime > 0 then
            if gameState.bButtonHoldTime < gameState.longPressThreshold then
                -- 短按B键：返回逻辑
                if gameState.isPanelVisible() then
                    print("有面板显示时短按B键无效果，请长按关闭面板")
                elseif gameState.isInSubMenu() then
                    gameState.popMenu()
                    print("返回上一级菜单")
                else
                    gameState.currentMode = "panel_switch"
                    print("进入面板切换模式")
                end
            end
            gameState.bButtonHoldTime = 0
        end
    end
end

return mainController
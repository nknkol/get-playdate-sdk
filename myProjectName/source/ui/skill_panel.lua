-- ui/skill_panel.lua
local gfx <const> = playdate.graphics

-- 获取当前菜单数据
local function getCurrentMenu()
    local l = LangMgr.get()
    
    if GameState.currentMenuId == "main" then
        return l.menu  -- 主菜单
    elseif GameState.currentMenuData then
        return GameState.currentMenuData  -- 自定义菜单数据
    else
        return l.menu  -- 默认返回主菜单
    end
end

local skillPanel = {}

function skillPanel.draw(state)
    if not state.showSkill then
        return
    end
    
    -- 计算技能面板位置（屏幕顶部）
    local panelHeight = state.screenOffset  -- 正值，表示向下偏移的距离
    local panelY = panelHeight - state.skillPanelHeight  -- 面板从屏幕上方滑入
    
    if panelHeight <= 0 then
        return
    end
    
    -- 绘制技能面板背景
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, panelY, 400, state.skillPanelHeight)
    
    -- 绘制边框
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, panelY, 400, state.skillPanelHeight)
    
    -- 绘制底部分割线
    gfx.drawLine(0, panelY + state.skillPanelHeight, 400, panelY + state.skillPanelHeight)
    
    -- 只有当面板完全展开时才显示内容
    if state.screenOffset >= state.skillPanelHeight * 0.8 then
        local textY = panelY + 8
        local l = LangMgr.get()
        
        -- 技能面板标题
        gfx.drawText(l.ui.skillPanel or "⚡ 技能说明", 10, textY)
        gfx.drawText(l.ui.closeHint or "长按 B 键关闭", 250, textY)
        
        -- 获取当前菜单和选中项
        local currentMenu = getCurrentMenu()
        if currentMenu and currentMenu[state.selectedIndex] then
            local currentSkill = currentMenu[state.selectedIndex]
            
            -- 根据当前菜单类型显示不同的信息
            if state.currentMenuId == "main" then
                -- 主菜单：显示技能详细信息
                local skillInfo = l.skills and l.skills[currentSkill]
                if skillInfo then
                    -- 绘制技能信息
                    gfx.drawText("🎯 " .. currentSkill, 10, textY + 18)
                    gfx.drawText(skillInfo.desc, 10, textY + 34)
                    gfx.drawText(skillInfo.cost, 10, textY + 50)
                    gfx.drawText(skillInfo.effect, 200, textY + 50)
                else
                    -- 回退到默认描述
                    gfx.drawText("🎯 " .. currentSkill, 10, textY + 18)
                    gfx.drawText("暂无详细说明", 10, textY + 34)
                end
            elseif state.currentMenuId == "attack_target" then
                -- 攻击目标菜单：显示目标信息
                gfx.drawText("🎯 目标: " .. currentSkill, 10, textY + 18)
                gfx.drawText("攻击这个目标将造成物理伤害", 10, textY + 34)
                
                -- 根据不同目标显示不同信息
                if currentSkill == "哥布林" or currentSkill == "Goblin" then
                    gfx.drawText("生命值: 30 | 防御: 2", 10, textY + 50)
                elseif currentSkill == "骷髅兵" or currentSkill == "Skeleton" then
                    gfx.drawText("生命值: 25 | 防御: 4", 10, textY + 50)
                elseif currentSkill == "魔法师" or currentSkill == "Mage" then
                    gfx.drawText("生命值: 20 | 防御: 1", 10, textY + 50)
                elseif currentSkill == "暗影刺客" or currentSkill == "Shadow Assassin" then
                    gfx.drawText("生命值: 35 | 防御: 3", 10, textY + 50)
                end
            elseif state.currentMenuId == "flee_confirm" then
                -- 撤退确认菜单
                gfx.drawText("🏃 " .. currentSkill, 10, textY + 18)
                if state.selectedIndex == 1 then
                    gfx.drawText("立即离开战斗，成功率70%", 10, textY + 34)
                    gfx.drawText("撤退失败时会受到额外伤害", 10, textY + 50)
                else
                    gfx.drawText("取消撤退，继续战斗", 10, textY + 34)
                    gfx.drawText("返回到主菜单", 10, textY + 50)
                end
            else
                -- 其他菜单：显示基本信息
                gfx.drawText("📋 " .. currentSkill, 10, textY + 18)
                gfx.drawText("当前选项的详细信息", 10, textY + 34)
            end
        else
            -- 错误处理
            gfx.drawText("⚠️ 无法获取选项信息", 10, textY + 18)
        end
    end
end

return skillPanel
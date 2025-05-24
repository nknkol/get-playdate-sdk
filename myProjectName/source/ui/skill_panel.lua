-- ui/skill_panel.lua
local gfx <const> = playdate.graphics

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
        
        -- 技能面板标题
        local l = LangMgr.get()
        gfx.drawText(l.ui.skillPanel or "⚡ 技能说明", 10, textY)
        gfx.drawText(l.ui.closeHint or "按 A 或 B 键关闭", 280, textY)
        
        -- 当前选中技能的详细说明
        if l.menu and l.menu[state.selectedIndex] then
            local currentSkill = l.menu[state.selectedIndex]
            
            -- 使用语言文件中的技能描述
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
        end
    end
end

return skillPanel
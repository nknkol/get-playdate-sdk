-- ui/attribute_panel.lua
local gfx <const> = playdate.graphics

local attributePanel = {}

function attributePanel.draw(state)
    if not state.showAttribute then
        return
    end
    
    -- 计算属性面板位置（屏幕底部）
    -- screenOffset为负值时表示向上偏移
    local panelHeight = math.abs(state.screenOffset)  -- 转为正值作为面板高度
    local panelY = 240 - panelHeight
    
    if panelHeight <= 0 then
        return
    end
    
    -- 绘制属性面板背景
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, panelY, 400, panelHeight)
    
    -- 绘制边框
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, panelY, 400, panelHeight)
    
    -- 绘制分割线
    gfx.drawLine(0, panelY, 400, panelY)
    
    -- 只有当面板完全展开时才显示内容
    if panelHeight >= state.attributePanelHeight * 0.8 then
        -- 示例属性信息
        local textY = panelY + 8
        gfx.drawText("攻击力: 15", 10, textY)
        gfx.drawText("防御力: 8", 150, textY)
        gfx.drawText("生命值: 100/120", 10, textY + 16)
        gfx.drawText("魔法值: 50/60", 150, textY + 16)
        gfx.drawText("金币: 250", 10, textY + 32)
        gfx.drawText("等级: 5", 150, textY + 32)
        
        -- 提示文字
        gfx.drawText("按 A 或 B 键关闭", 280, textY)
    end
end

return attributePanel
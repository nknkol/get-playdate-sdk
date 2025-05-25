
-- =====================================================
-- ui/attribute_panel.lua - 属性面板（底部滑入）
-- =====================================================

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics

local attributePanel = {}

-- ===== 属性面板绘制区域 =====
function attributePanel.draw(state)
    if not state.showAttribute then
        return
    end
    
    -- ===== 面板位置计算区域 =====
    local panelHeight = math.abs(state.screenOffset)  -- 转为正值作为面板高度
    local panelY = 240 - panelHeight
    
    if panelHeight <= 0 then
        return
    end
    
    -- ===== 背景和边框绘制区域 =====
    -- --- 背景 ---
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, panelY, 400, panelHeight)
    
    -- --- 边框和分割线 ---
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, panelY, 400, panelHeight)
    gfx.drawLine(0, panelY, 400, panelY)
    
    -- ===== 属性内容绘制区域 =====
    if panelHeight >= state.attributePanelHeight * 0.8 then
        local textY = panelY + 8
        
        -- --- 第一行属性 ---
        gfx.drawText("⚔️ 攻击力: 15", 10, textY)
        gfx.drawText("🛡️ 防御力: 8", 150, textY)
        
        -- --- 第二行属性 ---
        gfx.drawText("❤️ 生命值: 100/120", 10, textY + 16)
        gfx.drawText("⚡ 魔法值: 50/60", 150, textY + 16)
        
        -- --- 第三行属性 ---
        gfx.drawText("💰 金币: 250", 10, textY + 32)
        gfx.drawText("📈 等级: 5", 150, textY + 32)
        
        -- --- 操作提示 ---
        gfx.drawText("按 B 键关闭", 280, textY)
    end
end

return attributePanel
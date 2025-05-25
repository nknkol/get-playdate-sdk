-- =====================================================
-- ui/attribute_panel.lua - 属性面板（底部滑入，覆盖遮挡，抖动背景）
-- =====================================================

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics

local attributePanel = {}

-- ===== 抖动背景生成函数 =====
local function drawDitheredBackground(x, y, width, height)
    -- 先绘制白色背景
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, width, height)
    
    -- 绘制固定的抖动图案（模拟半透明效果）
    gfx.setColor(gfx.kColorBlack)
    
    -- 选项1：经典50%密度抖动图案
    for i = 0, width - 1 do
        for j = 0, height - 1 do
            if (i + j) % 2 == 0 then
                gfx.fillRect(x + i, y + j, 1, 1)
            end
        end
    end
    
    -- 如果想要其他密度，可以替换上面的代码：
    
    -- 选项2：25%密度（更透明）
    -- for i = 0, width - 1, 2 do
    --     for j = 0, height - 1, 2 do
    --         if (i / 2 + j / 2) % 2 == 0 then
    --             gfx.fillRect(x + i, y + j, 1, 1)
    --         end
    --     end
    -- end
    
    -- 选项3：75%密度（更不透明）
    -- for i = 0, width - 1 do
    --     for j = 0, height - 1 do
    --         if not ((i + j) % 4 == 1 or (i + j) % 4 == 2) then
    --             gfx.fillRect(x + i, y + j, 1, 1)
    --         end
    --     end
    -- end
end

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
    
    -- ===== 抖动背景绘制区域 =====
    drawDitheredBackground(0, panelY, 400, panelHeight)
    
    -- ===== 面板边框绘制区域 =====
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, panelY, 400, panelHeight)
    gfx.drawLine(0, panelY, 400, panelY)  -- 顶部分割线加粗
    gfx.drawLine(0, panelY + 1, 400, panelY + 1)  -- 双线效果
    
    -- ===== 属性内容绘制区域 =====
    if panelHeight >= state.attributePanelHeight * 0.8 then
        local textY = panelY + 8
        
        -- --- 面板标题 ---
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("📊 角色属性", 10, textY)
        gfx.drawText("长按 B 键关闭", 280, textY)
        
        -- --- 第一行属性 ---
        gfx.drawText("攻击力: 15", 10, textY + 16)
        gfx.drawText("防御力: 8", 150, textY + 16)
        gfx.drawText("敏捷: 12", 280, textY + 16)
        
        -- --- 第二行属性 ---
        gfx.drawText("生命值: 100/120", 10, textY + 32)
        gfx.drawText("魔法值: 50/60", 180, textY + 32)
        
        -- --- 第三行属性 ---
        gfx.drawText("金币: 250", 10, textY + 48)
        gfx.drawText("等级: 5", 120, textY + 48)
        gfx.drawText("经验: 1250/2000", 200, textY + 48)
        
        -- --- 装备信息（如果面板足够高） ---
        if panelHeight >= state.attributePanelHeight then
            gfx.drawText("武器: 铁剑 (+8攻击)", 10, textY + 64)
        end
    end
end

return attributePanel
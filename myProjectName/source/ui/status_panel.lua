-- =====================================================
-- ui/status_panel.lua - 状态面板（顶部固定显示）
-- =====================================================

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics

-- ===== 状态面板绘制区域 =====
local statusPanel = {}
function statusPanel.draw(state)
    -- --- 状态信息显示 ---
    local y = 150
    gfx.drawText("◆ 状态: 示例文字", 10, y)
end
return statusPanel

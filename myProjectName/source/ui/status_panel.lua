-- ui/status_panel.lua
local gfx <const> = playdate.graphics

local statusPanel = {}
function statusPanel.draw(state)
    local y = 150
    gfx.drawText("◆ 状态: 示例文字", 10, y)
end
return statusPanel

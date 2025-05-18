
-- ui/main_area.lua
local gfx <const> = playdate.graphics
local langMgr = LangMgr
local L
local function updateLang() L = langMgr.get() end

local mainArea = {}
function mainArea.draw(state)
    updateLang()
    -- 标题与提示
    gfx.drawText(L.ui.title, 10, 5)
    gfx.drawText(L.ui.prompt, 10, 25)
    -- 选项列表
    for i, option in ipairs(L.menu) do
        local y = 50 + (i - 1) * 20
        if i == state.selectedIndex then
            local w, h = gfx.getTextSize(option)
            gfx.fillRect(8, y - 2, w + 4, h)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            gfx.drawText(option, 10, y)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        else
            gfx.drawText(option, 10, y)
        end
    end
end
return mainArea


-- main.lua
import "CoreLibs/graphics"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics

-- 全局状态
-- main.lua
LangMgr = import "lang"
GameState = import "data/game_state"   -- ← 仅此一次
local controller = import "controllers/controller"
local mainArea = import "ui/main_area"
local statusPanel = import "ui/status_panel"


local CustomFont = gfx.font.new("fonts/Pixel32v1.9-12px-zh_hans")
gfx.setFont(CustomFont) -- 将加载的字体设置为当前活动字体


function playdate.update()
    controller.update()
    gfx.clear()
    mainArea.draw(GameState)
    if GameState.showStatus then
        statusPanel.draw(GameState)
    end
    playdate.timer.updateTimers()
end

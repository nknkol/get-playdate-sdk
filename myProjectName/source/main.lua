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


local CustomFont

CustomFont = gfx.font.new("fonts/Pixel32v1.9-12px-zh_hans") -- 字体在 source/fonts/ 目录下

if CustomFont then
    gfx.setFont(CustomFont) -- 将加载的字体设置为当前活动字体
    print("自定义字体 'Pixel32v1.9-12px-zh_hans' 已加载并设置为默认字体。")
else
    print("错误：无法加载自定义字体 'fonts/Pixel32v1.9-12px-zh_hans'。将使用系统默认字体。")
    -- 即使加载失败，Playdate通常会自动回退到系统字体，但打印错误有助于调试。
end

function playdate.update()
    controller.update()
    gfx.clear()
    mainArea.draw(GameState)
    if GameState.showStatus then
        statusPanel.draw(GameState)
    end
    playdate.timer.updateTimers()
end

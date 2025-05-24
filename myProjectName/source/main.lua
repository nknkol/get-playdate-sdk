-- main.lua
import "CoreLibs/graphics"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics

-- 全局状态和管理器
LangMgr = import "lang"
GameState = import "data/game_state"
local controller = import "controllers/controller"
local mainArea = import "ui/main_area"
local statusPanel = import "ui/status_panel"
local attributePanel = import "ui/attribute_panel"  -- 新增

-- 设置自定义字体
local CustomFont = gfx.font.new("fonts/Pixel32v1.9-12px-zh_hans")
gfx.setFont(CustomFont)

function playdate.update()
    -- 更新控制器
    controller.update()
    
    -- 更新动画
    GameState.updateAnimation()
    
    -- 清空屏幕
    gfx.clear()
    
    -- 绘制主界面区域
    mainArea.draw(GameState)
    
    -- 绘制状态面板（如果需要）
    if GameState.showStatus then
        statusPanel.draw(GameState)
    end
    
    -- 绘制属性面板（新增）
    if GameState.showAttribute then
        attributePanel.draw(GameState)
    end
    
    -- 更新计时器
    playdate.timer.updateTimers()
    
    -- 调试信息（可选，发布时删除）
    if playdate.isDebugBuild then
        gfx.drawText("Offset: " .. math.floor(GameState.screenOffset), 300, 5)
        gfx.drawText("Hold: " .. GameState.downButtonHoldTime, 300, 20)
    end
end
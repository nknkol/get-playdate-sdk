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
local attributePanel = import "ui/attribute_panel"
local skillPanel = import "ui/skill_panel"  -- 新增技能面板

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
    
    -- 绘制技能面板（最先绘制，在顶部）
    if GameState.showSkill then
        skillPanel.draw(GameState)
    end
    
    -- 绘制主界面区域
    mainArea.draw(GameState)
    
    -- 绘制状态面板（如果需要）
    if GameState.showStatus then
        statusPanel.draw(GameState)
    end
    
    -- 绘制属性面板（最后绘制，在底部）
    if GameState.showAttribute then
        attributePanel.draw(GameState)
    end
    
    -- 更新计时器
    playdate.timer.updateTimers()
    
    -- -- 调试信息（发布时可删除）
    -- if playdate.isDebugBuild then
    --     gfx.setColor(gfx.kColorBlack)
    --     gfx.drawText("Offset: " .. math.floor(GameState.screenOffset), 300, 5)
    --     gfx.drawText("Down: " .. GameState.downButtonHoldTime, 300, 20)
    --     gfx.drawText("Up: " .. GameState.upButtonHoldTime, 300, 35)
        
    --     -- 面板状态指示
    --     if GameState.isSkillVisible() then
    --         gfx.drawText("Skill Panel", 300, 50)
    --     elseif GameState.isAttributeVisible() then
    --         gfx.drawText("Attr Panel", 300, 50)
    --     end
    -- end
end
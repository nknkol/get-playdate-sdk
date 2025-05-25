-- main.lua - 主入口文件

-- ===== 核心库导入区域 =====
import "CoreLibs/graphics"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics

-- ===== 全局状态和管理器初始化区域 =====
LangMgr = import "lang"
GameState = import "data/game_state"
local controller = import "controllers/controller"

-- ===== UI组件导入区域 =====
local mainArea = import "ui/main_area"
local statusPanel = import "ui/status_panel"
local attributePanel = import "ui/attribute_panel"
local skillPanel = import "ui/skill_panel"

-- ===== 字体设置区域 =====
local CustomFont = gfx.font.new("fonts/Pixel32v1.9-12px-zh_hans")
gfx.setFont(CustomFont)

-- ===== 主游戏循环区域 =====
function playdate.update()
    -- --- 控制器更新区 ---
    controller.update()
    
    -- --- 动画更新区 ---
    GameState.updateAnimation()
    
    -- --- 屏幕绘制区 ---
    gfx.clear()
    
    -- 技能面板（顶层）
    if GameState.showSkill then
        skillPanel.draw(GameState)
    end
    
    -- 主界面区域（中层）
    mainArea.draw(GameState)
    
    -- 状态面板（中层）
    if GameState.showStatus then
        statusPanel.draw(GameState)
    end
    
    -- 属性面板（底层）
    if GameState.showAttribute then
        attributePanel.draw(GameState)
    end
    
    -- --- 定时器更新区 ---
    playdate.timer.updateTimers()
    
    -- ===== 调试信息区域（开发用）=====
    -- if playdate.isDebugBuild then
    --     gfx.setColor(gfx.kColorBlack)
    --     gfx.drawText("Offset: " .. math.floor(GameState.screenOffset), 300, 5)
    --     gfx.drawText("Down: " .. GameState.downButtonHoldTime, 300, 20)
    --     gfx.drawText("Up: " .. GameState.upButtonHoldTime, 300, 35)
    --     
    --     if GameState.isSkillVisible() then
    --         gfx.drawText("Skill Panel", 300, 50)
    --     elseif GameState.isAttributeVisible() then
    --         gfx.drawText("Attr Panel", 300, 50)
    --     end
    -- end
end
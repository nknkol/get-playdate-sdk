-- main.lua - 主入口文件（更新版）

-- ===== 核心库导入区域 =====
import "CoreLibs/graphics"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics

-- ===== 全局状态和管理器初始化区域 =====
-- 必须先初始化全局对象，再导入其他模块
LangMgr = import "lang"
GameState = import "data/game_state"

-- ===== UI组件导入区域 =====
local mainArea = import "ui/main_area"          -- 新版：文本显示区域
local menuArea = import "ui/menu_area"          -- 新增：菜单组件（保留复用）
local statusPanel = import "ui/status_panel"
local attributePanel = import "ui/attribute_panel"
local skillPanel = import "ui/skill_panel"

-- ===== 调试配置导入区域 =====
local debugConfig = import "debug_config"

-- ===== 控制器导入区域 =====
local controller = import "controllers/controller"

-- ===== 字体设置区域 =====
-- 检查字体文件是否存在，如果不存在则使用默认字体
local fontPath = "fonts/Pixel32v1.9-12px-zh_hans"
local CustomFont = nil

-- 尝试加载自定义字体，如果失败则使用系统默认字体
local success, font = pcall(function()
    return gfx.font.new(fontPath)
end)

if success and font then
    CustomFont = font
    gfx.setFont(CustomFont)
    print("成功加载自定义字体")
else
    print("使用系统默认字体")
end

-- ===== 初始化设置区域 =====
function playdate.gameWillPause()
    -- 游戏暂停时的处理
    print("游戏暂停")
end

function playdate.gameWillResume()
    -- 游戏恢复时的处理
    print("游戏恢复")
end

-- 安全初始化游戏状态
if GameState then
    GameState.currentMode = GameState.currentMode or "text_mode"  -- 默认使用文本模式
    print("游戏状态初始化完成，当前模式：" .. GameState.currentMode)
else
    print("警告：GameState 未正确初始化")
end

-- 加载调试配置
if debugConfig then
    debugConfig.loadConfig()
end

-- 设置示例文本内容
if controller and controller.setTextContent then
    controller.setTextContent("冒险者日志", {
        "欢迎来到地下城探险！",
        "",
        "这是一个文本滚动显示的示例。你可以使用以下操作：",
        "",
        "• ↑↓ 键：滚动文本内容",
        "• 长按 ↑ 键：显示技能面板",
        "• 长按 ↓ 键：显示属性面板",
        "• A 键：快速跳转（顶部↔底部）",
        "• B 键：切换模式或关闭面板",
        "• 摇杆：精细滚动控制",
        "",
        "---",
        "",
        "模式说明：",
        "当前模式：文本滚动模式",
        "按 B 键可以切换到其他模式。",
        "",
        "在菜单模式下，你可以使用原有的菜单导航功能。",
        "在面板切换模式下，可以快速切换各种面板。",
        "",
        "技能面板和属性面板在任何模式下都可以通过长按对应按键调出。",
        "",
        "---",
        "",
        "长文本测试：",
        "这里是一些额外的文本内容，用于测试滚动功能。",
        "你可以尝试滚动到这里，然后继续往下滚动。",
        "",
        "第一段落：探险开始",
        "当你踏进这座古老的地下城时，微弱的火把光芒照亮了前方的道路。",
        "墙壁上刻着神秘的符文，空气中弥漫着古老的魔法气息。",
        "",
        "第二段落：初次遭遇", 
        "走廊深处传来奇怪的声音，你小心翼翼地前进。",
        "突然，一群哥布林从阴影中跳了出来！",
        "",
        "第三段落：战斗经验",
        "经过几场战斗，你逐渐掌握了战斗的技巧。",
        "每个敌人都有自己的弱点，观察和学习是生存的关键。",
        "",
        "第四段落：宝藏发现",
        "在一个隐秘的房间里，你发现了一个古老的宝箱。",
        "里面装着各种有用的物品和神秘的魔法道具。",
        "",
        "第五段落：深入探索",
        "随着探索的深入，地下城变得越来越危险。",
        "但同时，你也变得更加强大和有经验。",
        "",
        "继续你的冒险吧，探险者！",
        "",
        "---",
        "",
        "[文本结束]"
    })
    print("示例文本内容设置完成")
    
    -- 确保切换到文本模式
    controller.switchToTextMode()
else
    print("警告：controller 未正确初始化，无法设置文本内容")
end

-- ===== 主游戏循环区域 =====
function playdate.update()
    -- --- 调试输入处理 ---
    if debugConfig then
        debugConfig.handleDebugInput()
    end
    
    -- --- 控制器更新区 ---
    if controller and controller.update then
        controller.update()
    end
    
    -- --- 动画更新区（确保每帧都更新） ---
    if GameState and GameState.updateAnimation then
        GameState.updateAnimation()
    end
    
    -- --- 屏幕绘制区 ---
    gfx.clear()
    
    -- 安全检查 GameState
    if not GameState then
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("错误：GameState 未初始化", 10, 50)
        return
    end
    
    -- ===== 根据模式绘制不同内容 =====
    local currentMode = GameState.currentMode or "text_mode"
    
    if currentMode == "text_mode" then
        -- 文本滚动模式：显示文本内容
        
        -- 技能面板（顶层）- 基于动画状态显示
        if (GameState.screenOffset > 0 or GameState.targetOffset > 0) and skillPanel then
            skillPanel.draw(GameState)
        end
        
        -- 主文本区域（中层）- 传递textController给mainArea
        if mainArea and controller then
            local textController = controller.getTextController()
            mainArea.draw(GameState, textController)
        end
        
        -- 状态面板（中层）
        if GameState.showStatus and statusPanel then
            statusPanel.draw(GameState)
        end
        
        -- 属性面板（底层）- 基于动画状态显示
        if (GameState.screenOffset < 0 or GameState.targetOffset < 0) and attributePanel then
            attributePanel.draw(GameState)
        end
        
    elseif currentMode == "main_sentence" then
        -- 菜单导航模式：显示菜单界面
        
        -- 技能面板（顶层）- 基于动画状态显示
        if (GameState.screenOffset > 0 or GameState.targetOffset > 0) and skillPanel then
            skillPanel.draw(GameState)
        end
        
        -- 绘制背景和标题
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("菜单导航模式", 10, 5)
        gfx.drawLine(10, 20, 390, 20)
        
        -- 主菜单区域（中层）
        if menuArea then
            menuArea.draw(GameState, 0, 30, 400, 150)
        end
        
        -- 状态面板（中层）
        if GameState.showStatus and statusPanel then
            statusPanel.draw(GameState)
        end
        
        -- 属性面板（底层）- 基于动画状态显示
        if (GameState.screenOffset < 0 or GameState.targetOffset < 0) and attributePanel then
            attributePanel.draw(GameState)
        end
        
    elseif currentMode == "panel_switch" then
        -- -- 面板切换模式：显示简单的切换界面
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.drawText("面板切换模式", 10, 50)
        -- gfx.drawText("↑ 键：状态面板", 10, 80)
        -- gfx.drawText("↓ 键：属性面板", 10, 100)
        -- gfx.drawText("B 键：返回文本模式", 10, 120)
        
        -- 状态面板
        if GameState.showStatus and statusPanel then
            statusPanel.draw(GameState)
        end
        
        -- 属性面板 - 基于动画状态显示
        if (GameState.screenOffset < 0 or GameState.targetOffset < 0) and attributePanel then
            attributePanel.draw(GameState)
        end
    end
    
    -- --- 定时器更新区 ---
    playdate.timer.updateTimers()
    
    -- ===== 调试信息显示区域 =====
    if debugConfig then
        debugConfig.drawDebugInfo(GameState, controller)
    end
end

-- ===== 游戏生命周期处理 =====
function playdate.gameWillTerminate()
    -- 保存调试配置
    if debugConfig then
        debugConfig.saveConfig()
    end
    
    -- 游戏终止时的清理工作
    print("游戏正在关闭...")
end

function playdate.gameWillPause()
    -- 游戏暂停时的处理
    print("游戏暂停")
end

function playdate.gameWillResume()
    -- 游戏恢复时的处理
    print("游戏恢复")
end

function playdate.deviceWillSleep()
    -- 设备进入睡眠模式
    print("设备进入睡眠模式")
end

function playdate.deviceDidUnlock()
    -- 设备解锁
    print("设备已解锁")
end

-- 初始化完成标志
print("main.lua 初始化完成，游戏开始运行")
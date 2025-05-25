-- debug_config.lua - 调试配置管理

-- ===== 调试配置区域 =====
local debugConfig = {
    -- 启用调试模式的条件
    enableDebug = true,          -- 总开关
    showFPS = false,            -- 显示帧率
    showMemory = false,         -- 显示内存使用
    showState = true,           -- 显示状态信息
    showScrollInfo = true,      -- 显示滚动信息
    showPanelInfo = false,      -- 显示面板信息
    
    -- 调试信息显示位置
    debugX = 250,
    debugY = 5,
    lineHeight = 15,
}

-- ===== 调试检查函数 =====
function debugConfig.isDebugMode()
    if not debugConfig.enableDebug then
        return false
    end
    
    -- 在模拟器中自动启用调试
    if playdate.isSimulator then
        return true
    end
    
    -- 其他调试条件
    -- 例如：特定按键组合、配置文件等
    return debugConfig.enableDebug
end

-- ===== 调试信息绘制函数 =====
function debugConfig.drawDebugInfo(gameState, controller)
    if not debugConfig.isDebugMode() then
        return
    end
    
    local gfx = playdate.graphics
    local x = debugConfig.debugX
    local y = debugConfig.debugY
    local lineHeight = debugConfig.lineHeight
    local line = 0
    
    gfx.setColor(gfx.kColorBlack)
    
    -- 显示当前模式
    if debugConfig.showState and gameState then
        local currentMode = gameState.currentMode or "unknown"
        gfx.drawText("Mode: " .. currentMode, x, y + line * lineHeight)
        line += 1
        
        -- 显示屏幕偏移
        local offset = gameState.screenOffset or 0
        gfx.drawText("Offset: " .. math.floor(offset), x, y + line * lineHeight)
        line += 1
    end
    
    -- 显示滚动信息
    if debugConfig.showScrollInfo and controller then
        -- 安全调用 getScrollInfo
        local success, scrollInfo = pcall(function()
            if controller.getScrollInfo then
                return controller.getScrollInfo()
            end
            return nil
        end)
        
        if success and scrollInfo then
            gfx.drawText("Scroll: " .. math.floor(scrollInfo.scrollPercent * 100) .. "%", x, y + line * lineHeight)
            line += 1
        else
            gfx.drawText("Scroll: N/A", x, y + line * lineHeight)
            line += 1
        end
    end
    
    -- 显示面板信息
    if debugConfig.showPanelInfo and gameState then
        local panelInfo = ""
        if gameState.isSkillVisible and gameState.isSkillVisible() then
            panelInfo = "Skill Panel"
        elseif gameState.isAttributeVisible and gameState.isAttributeVisible() then  
            panelInfo = "Attr Panel"
        else
            panelInfo = "No Panel"
        end
        gfx.drawText("Panel: " .. panelInfo, x, y + line * lineHeight)
        line += 1
    end
    
    -- 显示帧率
    if debugConfig.showFPS then
        -- 简单的帧率估算
        local currentTime = playdate.getCurrentTimeMilliseconds()
        if not debugConfig.lastFrameTime then
            debugConfig.lastFrameTime = currentTime
            debugConfig.frameCount = 0
            debugConfig.fps = 0
        else
            debugConfig.frameCount = (debugConfig.frameCount or 0) + 1
            local deltaTime = currentTime - debugConfig.lastFrameTime
            
            if deltaTime >= 1000 then  -- 每秒更新一次
                debugConfig.fps = math.floor(debugConfig.frameCount * 1000 / deltaTime)
                debugConfig.frameCount = 0
                debugConfig.lastFrameTime = currentTime
            end
        end
        
        gfx.drawText("FPS: " .. (debugConfig.fps or 0), x, y + line * lineHeight)
        line += 1
    end
    
    -- 显示内存使用（如果可用）
    if debugConfig.showMemory then
        -- Playdate Lua 中可能没有直接的内存统计API
        -- 这里可以添加自定义的内存追踪逻辑
        gfx.drawText("Memory: N/A", x, y + line * lineHeight)
        line += 1
    end
end

-- ===== 调试控制函数 =====
function debugConfig.toggleDebug()
    debugConfig.enableDebug = not debugConfig.enableDebug
    print("调试模式: " .. (debugConfig.enableDebug and "开启" or "关闭"))
end

function debugConfig.toggleFPS()
    debugConfig.showFPS = not debugConfig.showFPS
    print("FPS显示: " .. (debugConfig.showFPS and "开启" or "关闭"))
end

function debugConfig.toggleMemory()
    debugConfig.showMemory = not debugConfig.showMemory
    print("内存显示: " .. (debugConfig.showMemory and "开启" or "关闭"))
end

-- ===== 调试快捷键处理 =====
function debugConfig.handleDebugInput()
    -- 示例：同时按住 A + B + 摇杆按下 来切换调试模式
    if playdate.buttonIsPressed(playdate.kButtonA) and 
       playdate.buttonIsPressed(playdate.kButtonB) and
       playdate.isCrankDocked() == false then
        
        -- 避免重复触发，使用计时器或标志
        if not debugConfig.debugToggleCooldown then
            debugConfig.toggleDebug()
            debugConfig.debugToggleCooldown = 30  -- 30帧冷却时间
        end
    end
    
    -- 减少冷却时间
    if debugConfig.debugToggleCooldown then
        debugConfig.debugToggleCooldown -= 1
        if debugConfig.debugToggleCooldown <= 0 then
            debugConfig.debugToggleCooldown = nil
        end
    end
end

-- ===== 配置保存和加载 =====
function debugConfig.saveConfig()
    -- 保存调试配置到文件
    local configData = {
        enableDebug = debugConfig.enableDebug,
        showFPS = debugConfig.showFPS,
        showMemory = debugConfig.showMemory,
        showState = debugConfig.showState,
        showScrollInfo = debugConfig.showScrollInfo,
        showPanelInfo = debugConfig.showPanelInfo,
    }
    
    playdate.datastore.write(configData, "debug_config")
end

function debugConfig.loadConfig()
    -- 从文件加载调试配置
    local configData = playdate.datastore.read("debug_config")
    if configData then
        debugConfig.enableDebug = configData.enableDebug or debugConfig.enableDebug
        debugConfig.showFPS = configData.showFPS or debugConfig.showFPS
        debugConfig.showMemory = configData.showMemory or debugConfig.showMemory
        debugConfig.showState = configData.showState or debugConfig.showState
        debugConfig.showScrollInfo = configData.showScrollInfo or debugConfig.showScrollInfo
        debugConfig.showPanelInfo = configData.showPanelInfo or debugConfig.showPanelInfo
        
        print("调试配置已加载")
    end
end

return debugConfig
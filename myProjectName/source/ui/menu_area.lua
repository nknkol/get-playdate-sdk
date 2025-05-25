-- ui/menu_area.lua - 菜单组件（保留原有菜单功能供复用）

-- ===== 依赖导入区域 =====
local gfx <const> = playdate.graphics
local langMgr = LangMgr
local L
local function updateLang() L = langMgr.get() end

-- ===== 菜单数据获取区域 =====
local function getCurrentMenu()
    updateLang()
    
    if GameState.currentMenuId == "main" then
        return L.menu  -- 主菜单
    elseif GameState.currentMenuData then
        return GameState.currentMenuData  -- 自定义菜单数据
    else
        return L.menu  -- 默认返回主菜单
    end
end

-- --- 菜单标题获取 ---
local function getMenuTitle()
    if GameState.currentMenuId == "main" then
        return L.ui.prompt
    elseif GameState.currentMenuId == "attack_target" then
        return "选择攻击目标："
    elseif GameState.currentMenuId == "flee_confirm" then
        return "确认要撤退吗？"
    else
        return "请选择："
    end
end

-- ===== 菜单组件区域 =====
local menuArea = {}

function menuArea.draw(state, x, y, width, height)
    updateLang()
    
    -- ===== 参数默认值设置 =====
    x = x or 0
    y = y or 0
    width = width or 400
    height = height or 240
    
    -- ===== 裁剪区域设置 =====
    gfx.setClipRect(x, y, width, height)
    
    -- ===== 菜单标题绘制 =====
    local menuTitle = getMenuTitle()
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(menuTitle, x + 10, y + 10)
    
    -- --- 菜单层级提示 ---
    if state.isInSubMenu() then
        local depthInfo = "层级: " .. (state.getMenuDepth() + 1) .. " | 短按B键返回"
        gfx.drawText(depthInfo, x + 10, y + 25)
    end

    -- ===== 菜单选项列表绘制 =====
    local currentMenu = getCurrentMenu()
    if currentMenu then
        local startY = state.isInSubMenu() and y + 50 or y + 35
        local lineHeight = 18
        
        for i, option in ipairs(currentMenu) do
            local optionY = startY + (i - 1) * lineHeight
            
            -- 检查是否在可见区域内
            if optionY >= y and optionY <= y + height - lineHeight then
                if i == state.selectedIndex then
                    -- --- 高亮选中项 ---
                    local w, h = gfx.getTextSize(option)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillRect(x + 8, optionY - 2, w + 4, h)
                    
                    -- --- 反色文字 ---
                    gfx.setImageDrawMode(gfx.kDrawModeInverted)
                    gfx.drawText("▶ " .. option, x + 10, optionY)
                    gfx.setImageDrawMode(gfx.kDrawModeCopy)
                else
                    -- --- 普通选项 ---
                    gfx.setColor(gfx.kColorBlack)
                    gfx.drawText("  " .. option, x + 10, optionY)
                end
            end
        end
    else
        -- --- 错误处理 ---
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("错误: 无法加载菜单", x + 10, y + 35)
    end
    
    -- ===== 操作提示绘制 =====
    local hintY = y + height - 50
    gfx.setColor(gfx.kColorBlack)
    
    if state.isInSubMenu() then
        gfx.drawText("A键确认 | 短按B键返回", x + 10, hintY)
        gfx.drawText("长按 ↑ 键查看技能", x + 10, hintY + 15)
    else
        gfx.drawText("A键确认 | ↑↓ 选择", x + 10, hintY)
        gfx.drawText("长按 ↑ 键查看技能 | 长按 ↓ 键查看属性", x + 10, hintY + 15)
    end
    
    -- ===== 清理区域 =====
    gfx.clearClipRect()
end

-- ===== 菜单控制接口 =====
function menuArea.handleInput(state)
    -- 获取当前菜单
    local currentMenu = getCurrentMenu()
    if not currentMenu then return false end
    
    -- 处理上下键选择
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        state.selectedIndex -= 1
        if state.selectedIndex < 1 then
            state.selectedIndex = #currentMenu
        end
        return true
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        state.selectedIndex += 1
        if state.selectedIndex > #currentMenu then
            state.selectedIndex = 1
        end
        return true
    end
    
    return false
end

function menuArea.getCurrentSelection(state)
    local currentMenu = getCurrentMenu()
    if currentMenu and currentMenu[state.selectedIndex] then
        return currentMenu[state.selectedIndex], state.selectedIndex
    end
    return nil, nil
end

function menuArea.getMenuInfo()
    return {
        menu = getCurrentMenu(),
        title = getMenuTitle(),
        isInSubMenu = GameState.isInSubMenu(),
        menuDepth = GameState.getMenuDepth()
    }
end

return menuArea
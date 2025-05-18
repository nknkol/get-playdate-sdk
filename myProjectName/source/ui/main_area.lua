
-- -- ui/main_area.lua
-- local gfx <const> = playdate.graphics
-- local langMgr = LangMgr
-- local L
-- local function updateLang() L = langMgr.get() end

-- local mainArea = {}
-- function mainArea.draw(state)
--     updateLang()
--     -- 标题与提示
--     gfx.drawText(L.ui.title, 10, 5)
--             -- 添加分割线
--     local separatorY = 20 -- 调整 Y 坐标以适应你的布局
--     gfx.setColor(gfx.kColorBlack) -- 设置分割线颜色为黑色
--     gfx.drawLine(10, separatorY, 390, separatorY) -- 从 x=10 到 x=390 画一条水平线

--     gfx.drawText(L.ui.prompt, 10, 25)


--     -- 选项列表
--     for i, option in ipairs(L.menu) do
--         local y = 50 + (i - 1) * 20
--         if i == state.selectedIndex then
--             local w, h = gfx.getTextSize(option)
--             gfx.fillRect(8, y - 2, w + 4, h)
--             gfx.setImageDrawMode(gfx.kDrawModeInverted)
--             gfx.drawText(option, 10, y)
--             gfx.setImageDrawMode(gfx.kDrawModeCopy)
--         else
--             gfx.drawText(option, 10, y)
--         end
--     end
-- end
-- return mainArea


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

    -- -- 原来的选项列表循环 (注释掉或删除)
    -- for i, option in ipairs(L.menu) do
    --     local y = 50 + (i - 1) * 20
    --     if i == state.selectedIndex then
    --         local w, h = gfx.getTextSize(option)
    --         gfx.fillRect(8, y - 2, w + 4, h)
    --         gfx.setImageDrawMode(gfx.kDrawModeInverted)
    --         gfx.drawText(option, 10, y)
    --         gfx.setImageDrawMode(gfx.kDrawModeCopy)
    --     else
    --         gfx.drawText(option, 10, y)
    --     end
    -- end

    -- 只显示当前选中的选项
    if L.menu and L.menu[state.selectedIndex] then
        local selectedOptionText = L.menu[state.selectedIndex]
        local y = 50 -- 固定Y轴位置，或者根据你的布局调整
                     -- 如果你希望它仍然像之前列表中的第一个选项那样定位，
                     -- 并且上下键仍然可以切换（只是不显示其他选项），
                     -- 那么这里的 Y 可能不需要改变，或者只需要一个固定的绘制基线

        -- 绘制选中项 (可以保留高亮效果，也可以简化)
        local w, h = gfx.getTextSize(selectedOptionText)
        gfx.fillRect(8, y - 2, w + 4, h) -- 背景高亮
        gfx.setImageDrawMode(gfx.kDrawModeInverted) -- 反色文字
        gfx.drawText(selectedOptionText, 10, y) -- 绘制文本
        gfx.setImageDrawMode(gfx.kDrawModeCopy) -- 恢复绘制模式

        -- 如果不想要高亮和反色，可以简化为：
        -- gfx.drawText(selectedOptionText, 10, y)
    else
        -- 处理 L.menu 为空或 selectedIndex 无效的情况 (可选)
        print("警告: 无法获取选中的菜单选项。 L.menu 或 state.selectedIndex 可能有问题。")
    end

end
return mainArea
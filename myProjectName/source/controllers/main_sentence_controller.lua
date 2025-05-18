
-- controllers/main_sentence_controller.lua
local gameState = GameState
-- local langMgr = LangMgr
local l = LangMgr.get()

local mainController = {}
function mainController.update()
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        gameState.selectedIndex += 1
        if gameState.selectedIndex > #l.menu then
            gameState.selectedIndex = 1
        end
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        gameState.selectedIndex -= 1
        if gameState.selectedIndex < 1 then
            gameState.selectedIndex = #l.menu
        end
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        -- 长按B触发面板模式
        gameState.currentMode = "panel_switch"
    end
end
return mainController
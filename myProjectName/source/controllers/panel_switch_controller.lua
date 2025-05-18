
-- controllers/panel_switch_controller.lua
local gameState = GameState

local panelController = {}
function panelController.update()
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        gameState.showStatus = false
        gameState.showAttribute = true
        gameState.currentMode = "main_sentence"
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        gameState.showStatus = true
        gameState.showAttribute = false
        gameState.currentMode = "main_sentence"
    end
end
return panelController

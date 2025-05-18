
-- controllers/controller.lua
local gameState = GameState
local mainSentence = import "controllers/main_sentence_controller"
local panelSwitch = import "controllers/panel_switch_controller"

local controller = {}
function controller.update()
    if gameState.currentMode == "main_sentence" then
        mainSentence.update()
    elseif gameState.currentMode == "panel_switch" then
        panelSwitch.update()
    end
end
return controller

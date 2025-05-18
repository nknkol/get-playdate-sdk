import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "strings"

local gfx <const> = playdate.graphics

-- Localization strings
local strings = {
	en = {
		locationName = "Starting Village",
		status = {"HP: 100", "MP: 50", "Level: 5"},
		options = {
			{"View", "Use", "Discard"},
			{"Forward", "Back", "Left", "Right"},
			{"Save", "Load", "Quit"}
		}
	}
	-- Additional languages can be added here
}

local lang = strings.en
-- Variables for managing menu and input states
local selectedOption = 1
local selectedSubOption = 1
local inputText = {"A"}
local cursorPos = 1
local inputMode = 1 -- 1=Uppercase, 2=Lowercase, 3=Symbols
local inputChars = {
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	"abcdefghijklmnopqrstuvwxyz",
	".,!?-_:;'\"0123456789"
}
local currentCharIndex = 1

function playdate.update()
	gfx.clear()

	-- Draw status area (right sidebar)
	gfx.drawRect(320, 0, 80, 240)
	for i, line in ipairs(lang.status) do
		gfx.drawText(line, 325, (i - 1) * 20 + 10)
	end

	-- Draw location name at top
	gfx.drawText(lang.locationName, 10, 5)
	gfx.drawLine(0, 25, 320, 25)

	-- Draw menu options
	local baseY = 40
	for i, group in ipairs(lang.options) do
		local prefix = (i == selectedOption) and "> " or "  "
		local optionText = prefix .. group[selectedSubOption]
		gfx.drawText(optionText, 10, baseY + (i - 1) * 20)
	end

	-- Draw input text box
	gfx.drawRect(10, 160, 300, 30)
	for i, char in ipairs(inputText) do
		if i == cursorPos then
			gfx.fillRect(12 + (i - 1) * 16, 162, 16, 26)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.drawText(char, 14 + (i - 1) * 16, 165)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		else
			gfx.drawText(char, 14 + (i - 1) * 16, 165)
		end
	end
end

-- Handle up/down buttons for navigating menus or changing input characters
function playdate.upButtonDown()
	if cursorPos > 0 then
		currentCharIndex -= 1
		if currentCharIndex < 1 then currentCharIndex = #inputChars[inputMode] end
		inputText[cursorPos] = inputChars[inputMode]:sub(currentCharIndex, currentCharIndex)
	else
		selectedOption -= 1
		if selectedOption < 1 then selectedOption = #lang.options end
	end
end

function playdate.downButtonDown()
	if cursorPos > 0 then
		currentCharIndex += 1
		if currentCharIndex > #inputChars[inputMode] then currentCharIndex = 1 end
		inputText[cursorPos] = inputChars[inputMode]:sub(currentCharIndex, currentCharIndex)
	else
		selectedOption += 1
		if selectedOption > #lang.options then selectedOption = 1 end
	end
end

-- Handle left/right buttons for navigating sub-options or input cursor
function playdate.leftButtonDown()
	if cursorPos > 0 then
		cursorPos -= 1
		if cursorPos < 1 then cursorPos = 1 end
	else
		selectedSubOption -= 1
		if selectedSubOption < 1 then selectedSubOption = #lang.options[selectedOption] end
	end
end

function playdate.rightButtonDown()
	if cursorPos > 0 then
		cursorPos += 1
		if cursorPos > #inputText then
			table.insert(inputText, "A")
			currentCharIndex = 1
		end
	else
		selectedSubOption += 1
		if selectedSubOption > #lang.options[selectedOption] then selectedSubOption = 1 end
	end
end

-- -- Handle the A button for selecting options or entering input mode
-- local aPressTimer = nil
-- function playdate.AButtonDown()
-- 	aPressTimer = playdate.timer.new(1000, function()
-- 		inputMode += 1
-- 		if inputMode > 3 then inputMode = 1 end
-- 	end)
-- end

-- function playdate.AButtonUp()
-- 	if aPressTimer.active then
-- 		aPressTimer:remove()
-- 		if cursorPos == 0 then
-- 			cursorPos = 1
-- 			inputText = {"A"}
-- 		else
-- 			cursorPos = 0
-- 		end
-- 	end
-- end

local aPressTimer = nil
local longPressOccurred = false

function playdate.AButtonDown()
    longPressOccurred = false -- 重置长按标志
    -- 如果之前的计时器由于某些原因没有被正确移除，先移除
    if aPressTimer then
        aPressTimer:remove()
    end
    aPressTimer = playdate.timer.new(1000) -- 1秒算长按
    aPressTimer.timerEndedCallback = function()
        print("长按触发!")
        inputMode += 1
        if inputMode > 3 then inputMode = 1 end
        longPressOccurred = true
        aPressTimer = nil -- 计时器完成使命后，可以清空
    end
end

function playdate.AButtonUp()
    if aPressTimer then
        -- 如果计时器仍然存在（意味着可能还没到1秒，或者刚到1秒但回调还没来得及清掉它）
        aPressTimer:remove() -- 立即停止并移除计时器
        aPressTimer = nil

        if not longPressOccurred then
            print("短按触发!")
            if cursorPos == 0 then
                cursorPos = 1
                inputText = {"A"}
            else
                cursorPos = 0
            end
        end
    else
        -- 如果 aPressTimer 已经是 nil (可能因为长按已发生并清除了计时器)
        -- 或者 AButtonDown 没有被正确调用
        if not longPressOccurred then
            -- 这种情况下，如果长按也未发生，可能代表一个非常快速的按下和释放
            -- 或者是一个逻辑上的边缘情况。根据需要处理或忽略。
            -- 这里我们假设如果长按没发生，就按短按处理。
            print("短按触发! (timer was nil on up)")
            if cursorPos == 0 then
                cursorPos = 1
                inputText = {"A"}
            else
                cursorPos = 0
            end
        end
    end
    longPressOccurred = false -- 重置以备下次使用
end
-- Handle the B button for canceling or deleting characters
function playdate.BButtonDown()
	if cursorPos > 0 then
		table.remove(inputText, cursorPos)
		cursorPos -= 1
		if cursorPos < 1 then cursorPos = 0 end
	else
		selectedOption = 1
		selectedSubOption = 1
	end
end
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

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

-- Handle the A button for selecting options or entering input mode
local aPressTimer = nil
function playdate.AButtonDown()
	aPressTimer = playdate.timer.new(1000, function()
		inputMode += 1
		if inputMode > 3 then inputMode = 1 end
	end)
end

function playdate.AButtonUp()
	if aPressTimer.active then
		aPressTimer:remove()
		if cursorPos == 0 then
			cursorPos = 1
			inputText = {"A"}
		else
			cursorPos = 0
		end
	end
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
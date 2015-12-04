local textContainer = nil
local textContainerBack = nil
local active = false

function InfoDispBtnChange(sender)
	if checkbox_getState(sender) == cbChecked then
		InfoDispEnable()
	else
		InfoDispDisable()
	end
end

function InfoDispEnable()
	OMKStart()
	active = true
end

function InfoDispDisable()
	if textContainer ~= nil then object_destroy(textContainer) end
	if textContainerBack ~= nil then object_destroy(textContainerBack) end
	active = false
end

function InfoDispGetText()
	if IsPlayerValid() then
		local charBase = readInteger(0x1DEA6E0)
		local charData1 = readInteger(charBase + 0x34)
		local charData2 = readInteger(charBase + 0x40)
		
		local action = readBytes(charData1, 1)
		local xpos = readFloat(charData1 + 0x14)
		local ypos = readFloat(charData1 + 0x18)
		local zpos = ReadFloat(charData1 + 0x1C)
		local hspeed = readFloat(charData2 + 0x64)
		local vspeed = readFloat(charData2 + 0x68)
		local ospeed = math.sqrt(hspeed * hspeed + vspeed * vspeed)
		
		local text = string.format("Action ID: 0x%02X (%u)\n", action, action)
		text = text..string.format("X: %5.5f, Y: %5.5f, Z: %5.5f\n", xpos, ypos, zpos)
		text = text.."Speed:          (Horizontal)    (Vertical)\n"
		text = text..string.format("%5.5f %5.5f %5.5f", ospeed, hspeed, vspeed)
		
		return text
	else
		return ""
	end
end

function InfoDispUpdate()
	if OMKD3DHook ~= nil and active then
		if textContainer ~= nil then object_destroy(textContainer) end
		if textContainerBack ~= nil then object_destroy(textContainerBack) end
		
		local text = InfoDispGetText()
		textContainerBack = OMKD3DHook.createTextContainer(OMKFontMapShadow, 17, OMKD3DHook.Height - 119, text)
		textContainer = OMKD3DHook.createTextContainer(OMKFontMap, 16, OMKD3DHook.Height - 120, text)
	end
end
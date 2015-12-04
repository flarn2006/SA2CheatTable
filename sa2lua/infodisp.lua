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

local function BitfieldToString(num)
	local bit = 1
	local str = ""
	for i=1,16 do
		if Bitwise.bw_and(bit, num) > 0 then
			str = str.."1"
		else
			str = str.."."
		end
		if i == 8 then str = str.." " end
		bit = 2 * bit
	end
	return str
end

function InfoDispGetText()
	if IsPlayerValid() then
		local charBase = readInteger(0x1DEA6E0)
		local charData1 = readInteger(charBase + 0x34)
		local charData2 = readInteger(charBase + 0x40)
		
		local action = readBytes(charData1, 1)
		local status = readInteger(charData1 + 0x04)
		local xrot = readInteger(charData1 + 0x08)
		local yrot = readInteger(charData1 + 0x0C)
		local zrot = readInteger(charData1 + 0x10)
		local xpos = readFloat(charData1 + 0x14)
		local ypos = readFloat(charData1 + 0x18)
		local zpos = ReadFloat(charData1 + 0x1C)
		local hspeed = readFloat(charData2 + 0x64)
		local vspeed = readFloat(charData2 + 0x68)
		local ospeed = math.sqrt(hspeed * hspeed + vspeed * vspeed)
		
		local text = string.format("Action ID: 0x%02X (%03u) Status: %04X (%s)\n\n", action, action, status, BitfieldToString(status))
		text = text.."Position:\n"
		text = text..string.format("X: %-15.5f Y: %-15.5f Z: %-15.5f\n", xpos, ypos, zpos)
		text = text.."Rotation:\n"
		text = text..string.format("X: %08X        Y: %08X        Z: %08X\n\n", xrot, yrot, zrot)
		text = text.."Speed:         (Horizontal)   (Vertical)\n"
		text = text..string.format("%-14.5f %-14.5f %-14.5f", ospeed, hspeed, vspeed)
		
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
		textContainerBack = OMKD3DHook.createTextContainer(OMKFontMapShadow, 17, OMKD3DHook.Height - 239, text)
		textContainer = OMKD3DHook.createTextContainer(OMKFontMap, 16, OMKD3DHook.Height - 240, text)
	end
end
function ShowPhysicsPresetsClick(sender)
	if tonumber_original == nil then
		tonumber_original = tonumber
		tonumber = tonumber_new
	end
	PPPresetList = PPLoadPresets()
	local lbitems = listbox_getItems(PhysicsPresets_List)
	strings_clear(lbitems)
	for i,v in ipairs(PPPresetList) do
		strings_add(lbitems, v.Name)
	end
	form_show(PhysicsPresets)
end

function PhysicsPresetsApplyClick(sender)
	local data2 = readInteger(readInteger(0x1DEA6E0) + 0x40)
	local sel = PPPresetList[listbox_getItemIndex(PhysicsPresets_List) + 1]
	
	if data2 ~= nil and sel ~= nil then
		writeInteger(data2 + 0xC0, sel.HangTime)
		writeFloat(data2 + 0xC8, sel.HorizSpeedCap)
		writeFloat(data2 + 0xCC, sel.VertSpeedCap)
		writeFloat(data2 + 0xD0, sel.SpeedMod)
		writeFloat(data2 + 0xD8, sel.InitJumpSpeed)
		writeFloat(data2 + 0xF8, sel.AddWhileJumpHeld)
		writeFloat(data2 + 0xFC, sel.GroundAccel)
		writeFloat(data2 + 0x100, sel.AirAccel)
		writeFloat(data2 + 0x104, sel.GroundDecel)
		writeFloat(data2 + 0x108, sel.BrakeSpeed)
		writeFloat(data2 + 0x10C, sel.AirBrakeSpeed)
		writeFloat(data2 + 0x110, sel.AirDecel)
		writeFloat(data2 + 0x114, sel.RollingDecel)
		writeFloat(data2 + 0x138, sel.Gravity)
	end
end

function PPLoadPresets()
	local result = {}
	local columns = {}
	local isHeader = true
	
	for line in io.lines("sa2lua/physpresets.csv") do
		if isHeader then
			for i,v in ipairs(line:split(",")) do
				columns[v] = i
			end
			isHeader = false
		else
			local colsToRead = {"Name", "HangTime", "HorizSpeedCap", "VertSpeedCap", "SpeedMod", "InitJumpSpeed",
			                    "AddWhileJumpHeld", "GroundAccel", "AirAccel", "GroundDecel", "BrakeSpeed",
								"AirBrakeSpeed", "AirDecel", "RollingDecel", "Gravity"}
			local preset = {}
			local s = line:split(",")
			for i,v in ipairs(colsToRead) do
				if v == "Name" then
					preset[v] = s[columns[v]]
				else
					preset[v] = tonumber(s[columns[v]])
				end
			end
			table.insert(result, preset)
		end
	end
	
	return result
end

function tonumber_new(str)
	local n = tonumber_original(str)
	if n > 0 then
		if str:sub(1, 1) == "-" then
			return -n
		else
			return n
		end
	else
		return n
	end
end

PPPresetList = {}
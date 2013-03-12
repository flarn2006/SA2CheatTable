function ShowSavedLocationsClick(sender)
	form_show(SavedLocations)
end

function TPUpdateControls()
	local lbi = listbox_getItems(SavedLocations_LocationList)
	strings_clear(lbi)
    for i,v in ipairs(locNt) do
		strings_add(lbi, v)
    end
    if stage < 0 then
    	control_setCaption(SavedLocations_UpdateStageBtn, "Set Stage")
		control_setEnabled(SavedLocations_SaveListBtn, false)
		control_setEnabled(SavedLocations_SaveLocationBtn, false)
        control_setEnabled(SavedLocations_LocationNameBox, false)
        control_setCaption(SavedLocations_LocationNameBox, "")
    else
    	control_setCaption(SavedLocations_UpdateStageBtn, "Stage: "..stage)
        control_setEnabled(SavedLocations_SaveListBtn, true)
		control_setEnabled(SavedLocations_LocationNameBox, true)
        if control_getCaption(SavedLocations_LocationNameBox) ~= "" then
        	control_setEnabled(SavedLocations_SaveLocationBtn, true)
        else
        	control_setEnabled(SavedLocations_SaveLocationBtn, false)
        end
    end
end

function UpdateStageBtnClick(sender)
    stage = readBytes(0x1934B70, 1, false)
    control_setCaption(sender, "Stage: " .. stage)
    locNt = {}
	locXt = {}
	locYt = {}
	locZt = {}
    LoadLocationFile()
    TPUpdateControls()
end

function TeleportBtnClick(sender)
	local charPtr = readInteger(readInteger(0x1DEA6E0) + 0x34)
    local sel = listbox_getItemIndex(SavedLocations_LocationList) + 1
    if locXt[sel] ~= nil then
		writeFloat(charPtr + 0x14, locXt[sel])
    	writeFloat(charPtr + 0x18, locYt[sel])
    	writeFloat(charPtr + 0x1C, locZt[sel])
    end
end

function SaveLocationBtnClick(sender)
    local charPtr = readInteger(readInteger(0x1DEA6E0) + 0x34)
    local sel = listbox_getItemIndex(SavedLocations_LocationList) + 1
	table.insert(locNt, control_getCaption(SavedLocations_LocationNameBox))
    control_setCaption(SavedLocations_LocationNameBox, "")
    table.insert(locXt, readFloat(charPtr + 0x14))
    table.insert(locYt, readFloat(charPtr + 0x18))
    table.insert(locZt, readFloat(charPtr + 0x1C))
    TPUpdateControls()
end

function SaveListBtnClick(sender)
	lbitems = listbox_getItems(SavedLocations_LocationList)
    local file = io.open("sa2lua/teleport/stage"..stage..".loc", "w+")
	file:write(#locNt.."\n")
    for i,v in ipairs(locNt) do
		file:write(v.."\n")
        file:write(locXt[i].."\n")
        file:write(locYt[i].."\n")
        file:write(locZt[i].."\n")
    end
    file:close()
end

function LocationNameBoxChange(sender)
	TPUpdateControls()
end

function LoadLocationFile()
	local file = io.open("sa2lua/teleport/stage"..stage..".loc", "r")
    if file ~= nil then
		local count = tonumber(file:read())
        for i=1,count do
			table.insert(locNt, file:read())
            table.insert(locXt, tonumber(file:read()))
            table.insert(locYt, tonumber(file:read()))
            table.insert(locZt, tonumber(file:read()))
        end
        file:close()
    end
end

-- Initialization

stage = -1
locNt = {}
locXt = {}
locYt = {}
locZt = {}
TPUpdateControls()
OMKHelpText = [[Object Manipulation Keys:

A/D - Move on X axis
R/F - Move on Y axis
W/S - Move on Z axis
Q/E - Rotate around Y axis
Z - Duplicate object
X - Align to X/Z axes
C - Same as "Spawn Object" button
O/P - Select objects]]

function ObjManipKeysToggleClick(sender)
	OMKActive = (checkbox_getState(sender) == cbChecked)
	if OMKActive then
		OMKHotkeyA = createHotkey(OMKKeyHandler, VK_A)
		OMKHotkeyD = createHotkey(OMKKeyHandler, VK_D)
		OMKHotkeyR = createHotkey(OMKKeyHandler, VK_R)
		OMKHotkeyF = createHotkey(OMKKeyHandler, VK_F)
		OMKHotkeyW = createHotkey(OMKKeyHandler, VK_W)
		OMKHotkeyS = createHotkey(OMKKeyHandler, VK_S)
		OMKHotkeyQ = createHotkey(OMKKeyHandler, VK_Q)
		OMKHotkeyE = createHotkey(OMKKeyHandler, VK_E)
		OMKHotkeyZ = createHotkey(OMKKeyHandler, VK_Z)
		OMKHotkeyX = createHotkey(OMKKeyHandler, VK_X)
		OMKHotkeyC = createHotkey(OMKKeyHandler, VK_C)
		OMKHotkeyO = createHotkey(OMKKeyHandler, VK_O)
		OMKHotkeyP = createHotkey(OMKKeyHandler, VK_P)
		EnableLineDrawingIfNecessary()
	else
		object_destroy(OMKHotkeyA)
		object_destroy(OMKHotkeyD)
		object_destroy(OMKHotkeyR)
		object_destroy(OMKHotkeyF)
		object_destroy(OMKHotkeyW)
		object_destroy(OMKHotkeyS)
		object_destroy(OMKHotkeyQ)
		object_destroy(OMKHotkeyE)
		object_destroy(OMKHotkeyZ)
		object_destroy(OMKHotkeyX)
		object_destroy(OMKHotkeyC)
		object_destroy(OMKHotkeyO)
		object_destroy(OMKHotkeyP)
	end
end

function UpdateObjectSelCube()
	if EnableObjectSpawning ~= nil and readInteger(linedraw_objaddr) ~= nil then
		if OMKActive and readFloat(GetObjData1(objaddr, 0x14)) ~= nil then
			local radius = 10
			local x = readFloat(GetObjData1(objaddr, 0x14))
			local y = readFloat(GetObjData1(objaddr, 0x18))
			local z = readFloat(GetObjData1(objaddr, 0x1C))
			local x1 = x - 10
			local y1 = y - 10
			local z1 = z - 10
			local x2 = x + 10
			local y2 = y + 10
			local z2 = z + 10
			DrawCube3D("SelectedObject", x1, y1, z1, x2, y2, z2, ldcGreen)
		else
			RemoveCube("SelectedObject")
		end
	end
end

function ObjManipKeysHelpClick(sender)
	messageDialog(OMKHelpText, mtInformation, mbOK)
end

function OMKKeyHandler(sender)
	local inc = 4
	local x = readFloat(GetObjData1(objaddr, 0x14))
	local y = readFloat(GetObjData1(objaddr, 0x18))
	local z = readFloat(GetObjData1(objaddr, 0x1C))
	local r = readInteger(GetObjData1(objaddr, 0x0C))
	local curobj = objaddr
	
	if OMKActive then
		if x ~= nil then
				if isKeyPressed(VK_A) then x = x + inc
			elseif isKeyPressed(VK_D) then x = x - inc
			elseif isKeyPressed(VK_R) then y = y + inc
			elseif isKeyPressed(VK_F) then y = y - inc
			elseif isKeyPressed(VK_W) then z = z + inc
			elseif isKeyPressed(VK_S) then z = z - inc
			elseif isKeyPressed(VK_Q) then r = r + 0x1000
			elseif isKeyPressed(VK_E) then r = r - 0x1000
			elseif isKeyPressed(VK_Z) then OMKDuplicateObject()
			elseif isKeyPressed(VK_X) then
				x = 4 * round(x/4, 0)
				z = 4 * round(z/4, 0)
			end
		end
		
		-- The rest of the keys don't require a valid object selection to work.
		if isKeyPressed(VK_C) then
			SpawnObjectClick(SpawnObjectDlg_SpawnObject) --emulate button click
		elseif isKeyPressed(VK_O) then PrevObject() UpdateObjectSelCube()
		elseif isKeyPressed(VK_P) then NextObject() UpdateObjectSelCube()
		end
	end
	
	if curobj == objaddr then
		writeFloat(GetObjData1(objaddr, 0x14), x)
		writeFloat(GetObjData1(objaddr, 0x18), y)
		writeFloat(GetObjData1(objaddr, 0x1C), z)
		writeInteger(GetObjData1(objaddr, 0x0C), r)
	end
end

function OMKDuplicateObject()
	local routine = readInteger(objaddr + 0x10)
	local nameaddr = readInteger(objaddr + 0x44)
	local xpos = readFloat(GetObjData1(objaddr, 0x14))
	local ypos = readFloat(GetObjData1(objaddr, 0x18))
	local zpos = readFloat(GetObjData1(objaddr, 0x1C))
	local xrot = readInteger(GetObjData1(objaddr, 0x08))
	local yrot = readInteger(GetObjData1(objaddr, 0x0C))
	local zrot = readInteger(GetObjData1(objaddr, 0x10))
	local xscl = readFloat(GetObjData1(objaddr, 0x20))
	local yscl = readFloat(GetObjData1(objaddr, 0x24))
	local zscl = readFloat(GetObjData1(objaddr, 0x28))
	SpawnObject(routine, nameaddr, 0x0F, 0x02, false, xpos, ypos, zpos, xrot, yrot, zrot, xscl, yscl, zscl, 0)
end

OMKActive = false
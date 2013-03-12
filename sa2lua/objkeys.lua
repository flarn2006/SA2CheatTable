OMKHelpText = [[Object Manipulation Keys:

A/D - Move on X axis
R/F - Move on Y axis
W/S - Move on Z axis
Q/E - Rotate around Y axis
Z - Duplicate object
X - Align to X/Z axes
C - Same as "Spawn Object" button]]

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
	
	if OMKActive and x ~= nil then
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
		elseif isKeyPressed(VK_C) then
			SpawnObjectClick(SpawnObjectDlg_SpawnObject) --emulate button click
		end
	end
	
	writeFloat(GetObjData1(objaddr, 0x14), x)
	writeFloat(GetObjData1(objaddr, 0x18), y)
	writeFloat(GetObjData1(objaddr, 0x1C), z)
	writeInteger(GetObjData1(objaddr, 0x0C), r)
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
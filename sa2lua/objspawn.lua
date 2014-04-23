function ShowSpawnObjectClick(sender)
	form_show(SpawnObjectDlg)
end

function EnableObjPlacementClick(sender)
	EnableObjectSpawning()
	--debugProcess()
end

function EnableObjectSpawning()
	local hookaddr = allocateSharedMemory(1024)
	hookcmd = LoadBinaryFile("sa2lua/hook.bin", hookaddr) + hookaddr
	writeInteger(hookaddr + 0x02, hookcmd)
	writeBytes(0x77E780, 0xE9)
	writeInteger(0x77E781, hookaddr - 0x77E785)
	writeInteger(hookcmd, 0)
	fullAccess(0x42C645, 4)
	control_setEnabled(SpawnObjectDlg_SpawnObject, true)
	control_setEnabled(SpawnObjectDlg_ReplaceObject, true)
	control_setEnabled(SpawnObjectDlg_SpawnCylinder, true)
	control_setEnabled(CallFunc_Call, true)
	control_setEnabled(ObjectChain_ObjManipKeysToggle, true)
end

function SpawnObject(routine, name, flags, list, customname, xpos, ypos, zpos, xrot, yrot, zrot, xscl, yscl, zscl, delay)
	local nameaddr = name
	if readInteger(hookcmd) == nil then
		print("Object spawning not enabled!")
		return nil
	end
	if customname then
		nameaddr = AllocateString(name)
	end
	
	writeInteger(hookcmd, 1) -- tell the injected code to spawn an object
	writeInteger(hookcmd + 0x04, routine)
	writeInteger(hookcmd + 0x08, nameaddr)
	writeBytes(hookcmd + 0x0C, flags)
	writeInteger(hookcmd + 0x0D, list)
	writeInteger(hookcmd + 0x11, xrot)
	writeInteger(hookcmd + 0x15, yrot)
	writeInteger(hookcmd + 0x19, zrot)
	writeFloat(hookcmd + 0x1D, xpos)
	writeFloat(hookcmd + 0x21, ypos)
	writeFloat(hookcmd + 0x25, zpos)
	writeFloat(hookcmd + 0x29, xscl)
	writeFloat(hookcmd + 0x2D, yscl)
	writeFloat(hookcmd + 0x31, zscl)
	
	sp_routine_storage = routine -- We'll need this later.
	
	if delay > 0 then sleep(delay) end
	
	if readBytes(hookcmd, 1, false) == 0 then
		return readInteger(hookcmd + 0x04)
	else
		return nil
	end
end

function SpawnCylinderClick(sender)
	local xpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
	local ypos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
	local zpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
	objaddr = SpawnObject(0x6D6EE0, "Movable Cylinder", 3, 2, true, xpos, ypos, zpos, 0,0,0,0,0,0, 0)
	OCUpdateControls()
end

function SpawnObjectClick(sender)
	local xrot local yrot local zrot
	local routine = tonumber(control_getCaption(SpawnObjectDlg_MainRoutine), 16)
	local flags = tonumber(control_getCaption(SpawnObjectDlg_Flags), 16)
	local list = tonumber(control_getCaption(SpawnObjectDlg_ListID), 16)
	local copyrot = (checkbox_getState(SpawnObjectDlg_UsePlayerRot) == cbChecked)
	local customname = (objname == 0)
	if copyrot then
		xrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x08))
		yrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x0C))
		zrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x10))
		if routine == 0x6CFBF0 then
			yrot = 0xFFFF - yrot + 0x4000
		end
	else
		xrot = tonumber(control_getCaption(SpawnObjectDlg_RotX), 16)
		yrot = tonumber(control_getCaption(SpawnObjectDlg_RotY), 16)
		zrot = tonumber(control_getCaption(SpawnObjectDlg_RotZ), 16)
	end
	local xpos, ypos, zpos
	if OMKCursorMode then
		xpos = OMKCursorX
		ypos = OMKCursorY
		zpos = OMKCursorZ
	else
		xpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
		ypos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
		zpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
		xpos = xpos + tonumber(control_getCaption(SpawnObjectDlg_OffX))
		ypos = ypos + tonumber(control_getCaption(SpawnObjectDlg_OffY))
		zpos = zpos + tonumber(control_getCaption(SpawnObjectDlg_OffZ))
	end
	local xscl = tonumber(control_getCaption(SpawnObjectDlg_SclX))
	local yscl = tonumber(control_getCaption(SpawnObjectDlg_SclY))
	local zscl = tonumber(control_getCaption(SpawnObjectDlg_SclZ))
	if customname then name = control_getCaption(SpawnObjectDlg_ObjectName) else name = objname end
	objaddr = SpawnObject(routine, name, flags, list, customname, xpos, ypos, zpos, xrot, yrot, zrot, xscl, yscl, zscl, 0)
	spawnqueue = {}
	OCUpdateControls()
end

function SpawnObjectHere(routine, name, flags, list, customname, xscl, yscl, zscl)
	local xpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
	local ypos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
	local zpos = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
	local xrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x08))
	local yrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x0C))
	local zrot = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x10))
	SpawnObject(routine, name, flags, list, customname, xpos, ypos, zpos, xrot, yrot, zrot, xscl, yscl, zscl, 0)
end

function ReplaceObjectClick(sender)
	local xrot local yrot local zrot
	local routine = tonumber(control_getCaption(SpawnObjectDlg_MainRoutine), 16)
	local flags = tonumber(control_getCaption(SpawnObjectDlg_Flags), 16)
	local list = tonumber(control_getCaption(SpawnObjectDlg_ListID), 16)
	local copyrot = (checkbox_getState(SpawnObjectDlg_UsePlayerRot) == cbChecked)
	local customname = (objname == 0)
	if customname then name = control_getCaption(SpawnObjectDlg_ObjectName) else name = objname end
	if copyrot then
		xrot = readFloat(GetObjData1(objaddr, 0x08))
		yrot = readFloat(GetObjData1(objaddr, 0x0C))
		zrot = readFloat(GetObjData1(objaddr, 0x10))
	else
		xrot = tonumber(control_getCaption(SpawnObjectDlg_RotX), 16)
		yrot = tonumber(control_getCaption(SpawnObjectDlg_RotY), 16)
		zrot = tonumber(control_getCaption(SpawnObjectDlg_RotZ), 16)
	end
	local xpos = readFloat(GetObjData1(objaddr, 0x14))
	local ypos = readFloat(GetObjData1(objaddr, 0x18))
	local zpos = readFloat(GetObjData1(objaddr, 0x1C))
	local xscl = tonumber(control_getCaption(SpawnObjectDlg_SclX))
	local yscl = tonumber(control_getCaption(SpawnObjectDlg_SclY))
	local zscl = tonumber(control_getCaption(SpawnObjectDlg_SclZ))
	writeInteger(objaddr + 0x10, 0x46F720) -- Delete the selected object
	OLRemoveObject(objaddr)
	local obj = SpawnObject(routine, name, flags, list, customname, xpos, ypos, zpos, xrot, yrot, zrot, xscl, yscl, zscl, 0)
	objaddr = obj
	OCUpdateControls()
end

function GetStageObjList()
	local list = {}
	local objlist = readInteger(0x1DDE268)
	local count = readInteger(objlist)
	objlist = readInteger(objlist + 0x04)
	
	for i=0,count-1 do
		local entry = {}
		entry.name = readInteger(objlist + 0x0C)
		entry.namestr = readString(entry.name, 64)
		entry.flags = readBytes(objlist, 1, false)
		entry.list = readBytes(objlist + 0x01, 1, false)
		entry.routine = readInteger(objlist + 0x08)
		table.insert(list, entry)
		objlist = objlist + 0x10
	end
	
	return list
end

function PopulateObjListClick(sender)
	local objlist = readInteger(0x1DDE268)
	local count = readInteger(objlist)
	objlist = readInteger(objlist + 0x04)
	ol_name = {}
	ol_namestr = {}
	ol_flags = {}
	ol_list = {}
	ol_routine = {}
	for i=0,count-1 do
		local name = readInteger(objlist + 0x0C)
		local flags = readBytes(objlist, 1, false)
		local list = readBytes(objlist + 0x01, 1, false)
		local routine = readInteger(objlist + 0x08)
		table.insert(ol_name, name)
		table.insert(ol_namestr, readString(name, 64))
		table.insert(ol_flags, flags)
		table.insert(ol_list, list)
		table.insert(ol_routine, routine)
		objlist = objlist + 0x10
	end
	local lbitems = listbox_getItems(SpawnObjectDlg_ObjectList)
	strings_clear(lbitems)
	for i,v in ipairs(ol_namestr) do
		strings_add(lbitems, v)
	end
end

function ObjectListSelectionChange(sender, user)
	local index = listbox_getItemIndex(sender) + 1
	objname = ol_name[index]
	control_setCaption(SpawnObjectDlg_ObjectName, ol_namestr[index])
	control_setCaption(SpawnObjectDlg_MainRoutine, num2hex(ol_routine[index]))
	control_setCaption(SpawnObjectDlg_Flags, num2hex(ol_flags[index]))
	control_setCaption(SpawnObjectDlg_ListID, num2hex(ol_list[index]))
end

function ObjectNameChange(sender)
	local index = listbox_getItemIndex(SpawnObjectDlg_ObjectList) + 1
	local defaultname = ol_namestr[index]
	if control_getCaption(sender) ~= defaultname then
		objname = 0
	else
		objname = ol_name[index]
	end
end

function CheckForSpawnedObject()
	if hookcmd ~= nil and readInteger(hookcmd) == -1 then
		writeInteger(hookcmd, 0)
		local flags = readBytes(hookcmd + 0x0C, 1, false)
		local list = readInteger(hookcmd + 0x0D)
		local addr = readInteger(hookcmd + 0x04)
		local objname = readString(readInteger(addr + 0x44), 64)
		if objname:sub(1,5) == "$Lua$" then
			object_callbacks[objname:sub(6)](addr)
		else
			objaddr = addr
			OCUpdateControls()
			UpdateRemote()
			OLAddObject(objaddr, sp_routine_storage, flags, list)
			SpawnNextObject()
		end
	end
end

function UsePlayerRotChange(sender)
	local enable = not (checkbox_getState(sender) == cbChecked)
	control_setEnabled(SpawnObjectDlg_RotX, enable)
	control_setEnabled(SpawnObjectDlg_RotY, enable)
	control_setEnabled(SpawnObjectDlg_RotZ, enable)
	control_setEnabled(SpawnObjectDlg_SpawnRotSetZero, enable)
end

function SpawnRotSetZeroClick(sender)
	control_setCaption(SpawnObjectDlg_RotX, "0")
	control_setCaption(SpawnObjectDlg_RotY, "0")
	control_setCaption(SpawnObjectDlg_RotZ, "0")
end

function SpawnSclSetOneClick(sender)
	control_setCaption(SpawnObjectDlg_SclX, "1")
	control_setCaption(SpawnObjectDlg_SclY, "1")
	control_setCaption(SpawnObjectDlg_SclZ, "1")
end

function SpawnSclSetZeroClick(sender)
	control_setCaption(SpawnObjectDlg_SclX, "0")
	control_setCaption(SpawnObjectDlg_SclY, "0")
	control_setCaption(SpawnObjectDlg_SclZ, "0")
end

function PopObjListCommonClick(sender)
	ol_name = {}
	ol_namestr = {}
	ol_flags = {}
	ol_list = {}
	ol_routine = {}
	for s in io.lines("sa2lua/objectlist.csv") do
		local tbl = s:split(",")
		table.insert(ol_name, 0)
		table.insert(ol_namestr, tbl[1])
		table.insert(ol_flags, tonumber(tbl[2], 16))
		table.insert(ol_list, tonumber(tbl[3], 16))
		table.insert(ol_routine, tonumber(tbl[4], 16))
	end
	local lbitems = listbox_getItems(SpawnObjectDlg_ObjectList)
	strings_clear(lbitems)
	for i,v in ipairs(ol_namestr) do
		strings_add(lbitems, v)
	end
end

function ObjectListDblClick(sender)
	local index = listbox_getItemIndex(sender) + 1
	if index > 0 then
		local helpstr = ""
		local rthex = num2hex(ol_routine[index])
		local file = io.open("sa2lua/objhelp/"..rthex..".txt")
		if file == nil then
			helpstr = "No help is available for this object. (yet)"
		else
			helpstr = file:read("*a")
			file:close()
		end
		messageDialog(helpstr, mtInformation, mbOK)
	end
end

function ToggleCollisionBtnClick(sender)
	local addr = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x2C)) + 0x06
	if readBytes(addr, 1, false) == 0x00 then
		--Collision is currently off; turn it on
		writeBytes(addr, 0x02)
		UpdateCollisionButtonCaption(true)
	else
		--Collision is currently on; turn it off
		writeBytes(addr, 0x00)
		UpdateCollisionButtonCaption(false)
	end
end

function UpdateCollisionButtonCaption(isEnabled)
	if isEnabled == nil and IsPlayerValid() then
		local addr = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x2C)) + 0x06
		isEnabled = (readBytes(addr, 1, false) ~= 0x00)
	end
	
	if isEnabled then
		control_setCaption(SpawnObjectDlg_ToggleCollision, "Collision ON")
	else
		control_setCaption(SpawnObjectDlg_ToggleCollision, "Collision OFF")
	end
end

function OffsetSetZeroClick(sender)
	control_setCaption(SpawnObjectDlg_OffX, "0")
	control_setCaption(SpawnObjectDlg_OffY, "0")
	control_setCaption(SpawnObjectDlg_OffZ, "0")
end

dofile("sa2lua/spawnedlist.lua")
dofile("sa2lua/objfile.lua")

object_callbacks = {DrawLine3D = DrawLineObjectCallback}

hookcmd = nil
objname = 0
ol_name = {}
ol_namestr = {}
ol_flags = {}
ol_list = {}
ol_routine = {}
control_setEnabled(SpawnObjectDlg_SpawnObject, false)
control_setEnabled(SpawnObjectDlg_ReplaceObject, false)
control_setEnabled(SpawnObjectDlg_SpawnCylinder, false)
strings_clear(listbox_getItems(SpawnObjectDlg_ObjectList))
-- objkeys.lua is an "Artifact Title". This file now contains most (if not all) of the code for Live Edit Mode.
OMKHelpDlgText = [[Gamepad controls:
Press DOWN to activate cursor
Hold LEFT to move selected object
Hold UP to rotate selected object
Hold RIGHT for object-specific action

Legacy keyboard controls:

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
		OMKStart()
	else
		OMKStop()
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
			local radius = OMKSelBoxRadiusOverride[readInteger(objaddr + 0x10)] or 10
			if radius ~= 0 then
				local x = readFloat(GetObjData1(objaddr, 0x14))
				local y = readFloat(GetObjData1(objaddr, 0x18))
				local z = readFloat(GetObjData1(objaddr, 0x1C))
				local x1 = x - radius
				local y1 = y - radius
				local z1 = z - radius
				local x2 = x + radius
				local y2 = y + radius
				local z2 = z + radius
				DrawCube3D("SelectedObject", x1, y1, z1, x2, y2, z2, SelectionBoxColor)
			end
		else
			RemoveCube("SelectedObject")
		end
	end
end

function ObjManipKeysHelpClick(sender)
	messageDialog(OMKHelpDlgText, mtInformation, mbOK)
end

function OMKKeyHandler(sender)
	if getForegroundProcess() == getOpenedProcessID() then
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

function UpdateControllerState()
	local controller_last = {}
	
	for k,v in pairs(controller) do
		controller_last[k] = v
	end
	
	controller.buttons = readInteger(0x1A52C4C) or 0
	controller.leftX = readInteger(0x1A52C50) or 0
	controller.leftY = readInteger(0x1A52C54) or 0
	controller.rightX = readInteger(0x1A52C58) or 0
	controller.rightY = readInteger(0x1A52C5C) or 0
	controller.leftTrigger = readInteger(0x1A52C60) or 0
	controller.rightTrigger = readInteger(0x1A52C64) or 0
	controller.left = (Bitwise.bw_and(controller.buttons, 1) > 0)
	controller.right = (Bitwise.bw_and(controller.buttons, 2) > 0)
	controller.down = (Bitwise.bw_and(controller.buttons, 4) > 0)
	controller.up = (Bitwise.bw_and(controller.buttons, 8) > 0)
	controller.a = (Bitwise.bw_and(controller.buttons, 256) > 0)
	controller.b = (Bitwise.bw_and(controller.buttons, 512) > 0)
	controller.x = (Bitwise.bw_and(controller.buttons, 1024) > 0)
	controller.y = (Bitwise.bw_and(controller.buttons, 2048) > 0)
	controller.start = (Bitwise.bw_and(controller.buttons, 4096) > 0)
	
	controller.edge = {}
	for i,v in ipairs({"left", "right", "down", "up", "a", "b", "x", "y", "start"}) do
		controller.edge[v] = (controller_last[v] ~= controller[v])
	end
end

function HandleControllerState()
	-- These first two lines enable independent detection of the triggers and the right analog stick.
	writeBytes(0x425910, 0x90, 0x90, 0x90)
	writeBytes(0x425A10, 0x90, 0x90, 0x90)
	SelectionBoxColor = ldcGreen
	if OMKActive then OMKCurrentMode = "default" else OMKCurrentMode = "off" end
	OMKHelpText = "- LIVE EDIT MODE -"
	if OMKActive and IsPlayerValid() then
		if readInteger(GetObjData1(objaddr, 0)) ~= nil then
			local cam = math.rad(readInteger(0x1DCFF1C) * (360 / 0x10000))
			
			--[[local testX = readFloat(GetObjData1(objaddr, 0x14))
			local testY = readFloat(GetObjData1(objaddr, 0x18))
			local testZ = readFloat(GetObjData1(objaddr, 0x1C))
			
			local offsetX = 50
			local offsetZ = 0
			local rotatedX = offsetX*math.cos(-cam) - offsetZ*math.sin(-cam)
			local rotatedZ = offsetX*math.sin(-cam) + offsetZ*math.cos(-cam)
			DrawLine3D("test1", testX, testY, testZ, testX+rotatedX, testY, testZ+rotatedZ, ldcRed)
			offsetX = 0
			offsetZ = 50
			rotatedX = offsetX*math.cos(-cam) - offsetZ*math.sin(-cam)
			rotatedZ = offsetX*math.sin(-cam) + offsetZ*math.cos(-cam)
			DrawLine3D("test2", testX, testY, testZ, testX+rotatedX, testY, testZ+rotatedZ, ldcBlue)]]
			
			if controller.left and not OMKCursorMode then --move mode
				OMKCurrentMode = "move"
				OMKHelpText = [[- LIVE EDIT MODE -
MOVING SELECTION
Use right analog stick to move horizontally
Use triggers to move vertically]]
				OMKAppendObjDescription()
				SelectionBoxColor = ldcYellow
				writeBytes(0x174AFFE, 0)
				local speedMult = 1/64
				local x = controller.rightX
				local y = (controller.rightTrigger - controller.leftTrigger) / 2
				local z = -controller.rightY
				local rotated_x = x*math.cos(-cam) - z*math.sin(-cam)
				local rotated_z = x*math.sin(-cam) + z*math.cos(-cam)
				local objx = readFloat(GetObjData1(objaddr, 0x14)) + speedMult*rotated_x
				local objy = readFloat(GetObjData1(objaddr, 0x18)) + speedMult*y
				local objz = readFloat(GetObjData1(objaddr, 0x1C)) + speedMult*rotated_z
				writeFloat(GetObjData1(objaddr, 0x14), objx)
				writeFloat(GetObjData1(objaddr, 0x18), objy)
				writeFloat(GetObjData1(objaddr, 0x1C), objz)
			elseif controller.up and not OMKCursorMode then --rotate mode
				OMKCurrentMode = "rotate"
				OMKHelpText = [[- LIVE EDIT MODE -
ROTATING SELECTION
Use right analog stick to rotate around X/Z
Use triggers to rotate around Y
Press Y to set all angles to zero]]
				OMKAppendObjDescription()
				SelectionBoxColor = ldcMagenta
				writeBytes(0x174AFFE, 0)
				local speedMult = 16
				local x = controller.rightX
				local y = (controller.rightTrigger - controller.leftTrigger) / 2
				local z = controller.rightY
				local objx = readInteger(GetObjData1(objaddr, 0x08)) + speedMult*x
				local objy = readInteger(GetObjData1(objaddr, 0x0C)) + speedMult*y
				local objz = readInteger(GetObjData1(objaddr, 0x10)) + speedMult*z
				objx = Bitwise.bw_and(objx, 0xFFFF)
				objy = Bitwise.bw_and(objy, 0xFFFF)
				objz = Bitwise.bw_and(objz, 0xFFFF)
				writeInteger(GetObjData1(objaddr, 0x08), objx)
				writeInteger(GetObjData1(objaddr, 0x0C), objy)
				writeInteger(GetObjData1(objaddr, 0x10), objz)
				if controller.y then
					selObj.rx = 0
					selObj.ry = 0
					selObj.rz = 0
					UpdateObjFromData(selObj)
				end
			elseif controller.right and not OMKCursorMode then --special mode
				local Handler = OMKSpecialModeHandlers[selObj.routine]
				if Handler ~= nil then
					local helptext = Handler("getHelpText")
					OMKCurrentMode = "special"
					SelectionBoxColor = ldcRed
					writeBytes(0x174AFFE, 0)
					OMKHelpText = "- LIVE EDIT MODE -\n"..helptext
					OMKAppendObjDescription()
					local dX = controller.rightX
					local dY = (controller.rightTrigger - controller.leftTrigger) / 2
					local dZ = -controller.rightY
					local dXr = dX*math.cos(-cam) - dZ*math.sin(-cam)
					local dZr = dX*math.sin(-cam) + dZ*math.cos(-cam)
					Handler("handleState", dX, dY, dZ, dXr, dZr)
				end
			end
		end
		if controller.down and controller.edge.down then --toggle cursor mode
			OMKCursorMode = not OMKCursorMode
			if OMKCursorMode then
				OMKCurrentMode = "cursor"
				writeBytes(0x174AFFE, 0)
				OMKCursorX = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
				OMKCursorY = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
				OMKCursorZ = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
			else
				OMKCurrentMode = "default"
			end
		end
		if OMKCursorMode then
			OMKHelpText = [[- LIVE EDIT MODE -
CURSOR MODE
Use right analog stick to move cursor horizontally
Use triggers to move cursor vertically
Press X to copy selected object for placement (may not work or crash for some objects)
Press Y to center cursor on selected object
Press LEFT to place object: ]]..control_getCaption(SpawnObjectDlg_ObjectName)..[[

Press DOWN again to confirm object selection

X = ]]..tostring(OMKCursorX)..[[

Y = ]]..tostring(OMKCursorY)..[[

Z = ]]..tostring(OMKCursorZ)
			
			OMKAppendObjDescription()
			SelectionBoxColor = ldcBlue
			local speedMult = 1/64
			local x = controller.rightX
			local y = (controller.rightTrigger - controller.leftTrigger) / 2
			local z = -controller.rightY
			local cam = math.rad(readInteger(0x1DCFF1C) * (360 / 0x10000))
			local rotated_x = x*math.cos(-cam) - z*math.sin(-cam)
			local rotated_z = x*math.sin(-cam) + z*math.cos(-cam)
			OMKCursorX = OMKCursorX + speedMult*rotated_x
			OMKCursorY = OMKCursorY + speedMult*y
			OMKCursorZ = OMKCursorZ + speedMult*rotated_z
			DrawCursor3D("OMKCursor", OMKCursorX, OMKCursorY, OMKCursorZ, 10, ldcCyan)
			
			local minDistObjAddr = 0
			local minDistance = -1
			for i,v in ipairs(allObjects[2]) do
				if v.px ~= nil then
					local dX = v.px - OMKCursorX
					local dY = v.py - OMKCursorY
					local dZ = v.pz - OMKCursorZ
					local distance = math.sqrt(dX*dX + dY*dY + dZ*dZ)
					if distance < minDistance or minDistance == -1 then
						minDistance = distance
						minDistObjAddr = v.address
					end
				end
			end
			if minDistObjAddr ~= 0 then objaddr = minDistObjAddr end
			
			if controller.left and controller.edge.left then
				SpawnObjectClick(SpawnObjectDlg_SpawnObject) --simulate button press
			end
			
			if controller.x and controller.edge.x then
				SpawnObjectDlg_MainRoutine:setCaption(num2hex(selObj.routine))
				SpawnObjectDlg_Flags:setCaption("F")
				SpawnObjectDlg_ListID:setCaption(num2hex(selObj.list))
				SpawnObjectDlg_ObjectName:setCaption(selObj.name or "???")
				SpawnObjectDlg_RotX:setCaption(tostring(selObj.rx))
				SpawnObjectDlg_RotY:setCaption(tostring(selObj.ry))
				SpawnObjectDlg_RotZ:setCaption(tostring(selObj.rz))
				SpawnObjectDlg_SclX:setCaption(tostring(selObj.sx))
				SpawnObjectDlg_SclY:setCaption(tostring(selObj.sy))
				SpawnObjectDlg_SclZ:setCaption(tostring(selObj.sz))
			end
			
			if controller.y and controller.edge.y then
				if readInteger(GetObjData1(objaddr, 0)) ~= nil then
					OMKCursorX = readFloat(GetObjData1(objaddr, 0x14))
					OMKCursorY = readFloat(GetObjData1(objaddr, 0x18))
					OMKCursorZ = readFloat(GetObjData1(objaddr, 0x1C))
				end
			end
		else
			RemoveCursor("OMKCursor")
		end
		if not controller.left and not controller.up and not controller.right and not OMKCursorMode then
			SelectionBoxColor = ldcGreen
			writeBytes(0x174AFFE, 1)
		end
		if OMKTextContainer ~= nil then object_destroy(OMKTextContainer) end
		if OMKTextContainerBack ~= nil then object_destroy(OMKTextContainerBack) end
		if OMKD3DHook ~= nil then
			OMKTextContainerBack = OMKD3DHook.createTextContainer(OMKFontMapShadow, 17, 17, OMKHelpText)
			OMKTextContainer = OMKD3DHook.createTextContainer(OMKFontMap, 16, 16, OMKHelpText)
		end
	end
end

function OMKStart()
	OMKGetD3DHook()
	if OMKD3DHook ~= nil then
		local font = createFont()
		font.setName("Fixedsys")
		font.setSize(8)
		font.setColor(0xFFFF00)
		OMKFontMap = OMKD3DHook.createFontmap(font)
		local font_s = createFont()
		font_s.setName("Fixedsys")
		font_s.setSize(8)
		font_s.setColor(0x000000)
		OMKFontMapShadow = OMKD3DHook.createFontmap(font_s)
	end
end

function OMKStop()
	object_destroy(OMKTextContainer)
	object_destroy(OMKTextContainerBack)
end

function OMKGetD3DHook()
	-- UPDATE: Cheat Engine 6.4 supports reattaching the D3D hook.
	-- This function will now check for that and behave accordingly.
	
	-- Cheat Engine crashes if you call createD3DHook on a process if:
	--   1) createD3DHook has already been called on the same process, and
	--   2) Cheat Engine has been quit since the first time it was called.
	-- Unfortunately, this means it's not (yet) possible to save the D3D hook
	-- across CE sessions. Luckily, however, Cheat Engine is otherwise much
	-- less likely to crash than a hacked SA2, so it can still be useful.
	
	-- This function will read a previously-saved file to determine the PID
	-- of the last process it was called on. If OMKD3DHook is nil and the PID
	-- matches, it will proceed without the D3D hook. If OMKD3DHook is not nil
	-- and the PID matches, it will simply return the existing D3D hook. If
	-- the PID doesn't match, it will create a new hook, regardless of the
	-- status of OMKD3DHook.
	
	-- A non-existent file will be treated as a PID that doesn't match.
	
	local lastPID
	local thisPID = getOpenedProcessID()
	if thisPID == 0 then return nil end
	local file = io.open("sa2lua/lastPID.txt", "r")
	if (file == nil) then
		lastPID = nil
	else
		lastPID = file:read("*n")
		file:close()
	end
	
	file = io.open("sa2lua/lastPID.txt", "w+")
	file:write(tostring(thisPID))
	file:close()
	
	if lastPID == thisPID then
		if OMKD3DHook == nil then
			if getCEVersion() < 6.4 then
				return nil
			else
				OMKD3DHook = createD3DHook()
				return OMKD3DHook
			end
		else
			return OMKD3DHook
		end
	else
		OMKD3DHook = createD3DHook()
		return OMKD3DHook
	end
end

function OMKDrawObjects()
	-- DrawHandler(objdata, defaultColor, prefix)
	if OMKActive then
		for i,v in ipairs(allObjects[2]) do
			if OMKDrawHandlers[v.routine] ~= nil then
				local defaultColor
				if objaddr == v.address then
					defaultColor = SelectionBoxColor
				else
					defaultColor = ldcCyan
				end
				OMKDrawHandlers[v.routine](v, defaultColor, "OBJ#"..tonumber(v.address)..":")
			end
		end
	end
end

function OMKDescribeSelection()
	return [[
Selected Object: ]]..(selObj.name or "[unknown]")..[[

Position:        ]]..string.format("%4.5f | %4.5f | %4.5f", selObj.px, selObj.py, selObj.pz)..[[

Rotation:        ]]..string.format("%08X | %08X | %08X", selObj.rx, selObj.ry, selObj.rz)..[[

Scale:           ]]..string.format("%4.5f | %4.5f | %4.5f", selObj.sx, selObj.sy, selObj.sz)
end

function OMKAppendObjDescription()
	if selObj ~= nil then
		if selObj.px ~= nil then
			OMKHelpText = OMKHelpText.."\n\n"..OMKDescribeSelection()
		end
	end
end

function OMKDrawCube(obj, color, prefix)
	LDRotateY = -obj.ry
	LDRotateCtrX = obj.px
	LDRotateCtrY = obj.py
	LDRotateCtrZ = obj.pz
	-- rx, ry, and rz, starting here, mean radius, not rotation
	local rx = 11 + obj.sx
	local ry = 11 + obj.sy
	local rz = 11 + obj.sz
	local x1 = obj.px - rx
	local y1 = obj.py - ry
	local z1 = obj.pz - rz
	local x2 = obj.px + rx
	local y2 = obj.py + ry
	local z2 = obj.pz + rz
	DrawCube3D(prefix, x1, y1, z1, x2, y2, z2, color, true)
	LDResetRotation()
end

function OMKDrawCylinder(obj, color, prefix)
	DrawCylinder3D(prefix, obj.px, obj.py, obj.pz, 11+obj.sx, 11+obj.sy*2, 12, color, true)
end

function OMKDrawWall(obj, color, prefix)
	local temp = obj.sz
	obj.sz = 0
	OMKDrawCube(obj, color, prefix)
	obj.sz = temp
	LDRotateY = obj.ry
	LDRotateCtrX = obj.px
	LDRotateCtrY = obj.py
	LDRotateCtrZ = obj.pz
	-- Pushes in Z+ direction
	DrawLine3D(prefix.."arrow1", obj.px, obj.py, obj.pz, obj.px, obj.py, obj.pz + 30, color, true)
	DrawLine3D(prefix.."arrow2", obj.px, obj.py, obj.pz + 30, obj.px, obj.py + 5, obj.pz + 25, color, true)
	DrawLine3D(prefix.."arrow3", obj.px, obj.py, obj.pz + 30, obj.px, obj.py - 5, obj.pz + 25, color, true)
	LDResetRotation()
end

function OMKDrawScaleAsDestination(obj, color, prefix)
	local markerColor = ldcCyan
	if OMKCurrentMode == "special" then markerColor = ldcYellow end
	DrawLine3D(prefix.."connector", obj.px, obj.py, obj.pz, obj.sx, obj.sy, obj.sz, color, true)
	DrawCursor3D(prefix.."marker", obj.sx, obj.sy, obj.sz, 10, markerColor, true)
end

function OMKDrawSphereGravSw(obj, color, prefix)
	if objaddr == obj.address then --only draw if selected; drawing too many can cause lag in script
		local multiplier = 1/4
		DrawCircle3D(prefix.."1", obj.px, obj.py, obj.pz, obj.sx * multiplier, 25, color, true)
		LDRotateCtrX = obj.px
		LDRotateCtrY = obj.py
		LDRotateCtrZ = obj.pz
		LDRotateZ = 0x4000
		DrawCircle3D(prefix.."2", obj.px, obj.py, obj.pz, obj.sx * multiplier, 25, color, true)
		LDRotateZ = 0
		LDRotateX = 0x4000
		DrawCircle3D(prefix.."3", obj.px, obj.py, obj.pz, obj.sx * multiplier, 25, color, true)
		LDResetRotation()
	end
end

function OMKDrawSpringArrow(obj, color, prefix)
	if objaddr == obj.address or OMKDrawAllSpringArrows then
		local y2 = obj.py + 40 * obj.sy + 120
		local size = 10
		LDRotateCtrX = obj.px
		LDRotateCtrY = obj.py
		LDRotateCtrZ = obj.pz
		LDRotateX = obj.rx
		LDRotateY = obj.ry
		LDRotateZ = obj.rz
		DrawLine3D(prefix.."1", obj.px, obj.py, obj.pz, obj.px, y2, obj.pz, color, true)
		DrawLine3D(prefix.."2", obj.px, y2, obj.pz, obj.px - size, y2 - size, obj.pz, color, true)
		DrawLine3D(prefix.."3", obj.px, y2, obj.pz, obj.px + size, y2 - size, obj.pz, color, true)
		DrawLine3D(prefix.."4", obj.px, y2, obj.pz, obj.px, y2 - size, obj.pz - size, color, true)
		DrawLine3D(prefix.."5", obj.px, y2, obj.pz, obj.px, y2 - size, obj.pz + size, color, true)
		LDResetRotation()
	end
end

function OMKDrawGravTrigger(obj, color, prefix)
	LDRotateCtrX = obj.px
	LDRotateCtrY = obj.py
	LDRotateCtrZ = obj.pz
	LDRotateX = obj.rx
	LDRotateY = obj.ry
	LDRotateZ = obj.rz
	local arrowLength = 32
	local arrowHeadSize = 4
	local y2 = obj.py - arrowLength + arrowHeadSize
	DrawLine3D(prefix.."1", obj.px, obj.py, obj.pz, obj.px, obj.py - arrowLength, obj.pz, color, true)
	DrawLine3D(prefix.."2", obj.px, obj.py - arrowLength, obj.pz, obj.px - arrowHeadSize, y2, obj.pz, color, true)
	DrawLine3D(prefix.."3", obj.px, obj.py - arrowLength, obj.pz, obj.px + arrowHeadSize, y2, obj.pz, color, true)
	DrawLine3D(prefix.."4", obj.px, obj.py - arrowLength, obj.pz, obj.px, y2, obj.pz - arrowHeadSize, color, true)
	DrawLine3D(prefix.."5", obj.px, obj.py - arrowLength, obj.pz, obj.px, y2, obj.pz + arrowHeadSize, color, true)
	LDResetRotation()
end

function OMKSMHSetScaleLikePosition(request, dX, dY, dZ, dXr, dZr)
	-- Special mode handler that enables setting scale values in the same way as moving the object.
	-- Most useful if an object's scale values refer to a location on the map. (like rockets, etc.)
	SelectionBoxColor = ldcCyan
	if request == "getHelpText" then
		return [[
SETTING DESTINATION COORDINATES
Use right analog stick to move horizontally
Use triggers to move vertically
Press Y to set to object coordinates]]
	
	elseif request == "handleState" then
		local speedMult = 1/64
		local x = selObj.sx + dXr * speedMult
		local y = selObj.sy + dY * speedMult
		local z = selObj.sz + dZr * speedMult
		
		if controller.y and controller.edge.y then
			x = selObj.px
			y = selObj.py
			z = selObj.pz
		end
		
		selObj.sx = x
		selObj.sy = y
		selObj.sz = z
		UpdateObjFromData(selObj)
	else
		return nil
	end
end

function OMKSMHSetScaleNormally(request, dX, dY, dZ, dXr, dZr)
	if request == "getHelpText" then
		return [[
SETTING SCALE OF SELECTION
Use right analog stick to set X/Z scale
Use triggers to set Y scale]]

	elseif request == "handleState" then
		local speedMult = 1/64
		selObj.sx = selObj.sx + dX * speedMult
		selObj.sy = selObj.sy + dY * speedMult
		selObj.sz = selObj.sz + dZ * speedMult
		UpdateObjFromData(selObj)
	else
		return nil
	end
end

function OMKSMHSetSpringStrength(request, dX, dY, dZ, dXr, dZr)
	if request == "getHelpText" then
		return [[
SETTING SPRING STRENGTH
Use triggers to set strength]]

	elseif request == "handleState" then
		local speedMult = 1/256
		selObj.sy = selObj.sy + dY * speedMult
		UpdateObjFromData(selObj)
	else
		return nil
	end
end

OMKDrawHandlers = {}
OMKDrawHandlers[0x6E54E0] = OMKDrawCube --CCUBE
OMKDrawHandlers[0x6E6FC0] = OMKDrawCube --LINKLINK
OMKDrawHandlers[0x6E5470] = OMKDrawCylinder --CCYL
OMKDrawHandlers[0x6E5550] = OMKDrawWall --CWALL
OMKDrawHandlers[0x6D50F0] = OMKDrawScaleAsDestination --ROCKET
OMKDrawHandlers[0x640DB0] = OMKDrawScaleAsDestination --WARP (paintings in Death Chamber, etc.)
OMKDrawHandlers[0x6542F0] = OMKDrawSphereGravSw --GRAV_SW
OMKDrawHandlers[0x5AE140] = OMKDrawCube --SCOL
OMKDrawHandlers[0x6C4480] = OMKDrawSpringArrow --SPRA
OMKDrawHandlers[0x6C4E90] = OMKDrawSpringArrow --SPRB
OMKDrawHandlers[0x6D9310] = OMKDrawSpringArrow --3SPRING
OMKDrawHandlers[0x776730] = OMKDrawGravTrigger --SWDRNGC

OMKSpecialModeHandlers = {}
OMKSpecialModeHandlers[0x6D50F0] = OMKSMHSetScaleLikePosition --ROCKET
OMKSpecialModeHandlers[0x640DB0] = OMKSMHSetScaleLikePosition --WARP (see above)
OMKSpecialModeHandlers[0x6E54E0] = OMKSMHSetScaleNormally --CCUBE
OMKSpecialModeHandlers[0x6E6FC0] = OMKSMHSetScaleNormally --LINKLINK
OMKSpecialModeHandlers[0x6E5470] = OMKSMHSetScaleNormally --CCYL
OMKSpecialModeHandlers[0x6E5550] = OMKSMHSetScaleNormally --CWALL
OMKSpecialModeHandlers[0x5AE140] = OMKSMHSetScaleNormally --SCOL
OMKSpecialModeHandlers[0x6C4480] = OMKSMHSetSpringStrength --SPRA
OMKSpecialModeHandlers[0x6C4E90] = OMKSMHSetSpringStrength --SPRB
OMKSpecialModeHandlers[0x6D9310] = OMKSMHSetSpringStrength --3SPRING

OMKSelBoxRadiusOverride = {}
OMKSelBoxRadiusOverride[0x6E54E0] = 3
OMKSelBoxRadiusOverride[0x6E6FC0] = 3
OMKSelBoxRadiusOverride[0x6E5550] = 3
OMKSelBoxRadiusOverride[0x776730] = 3

OMKActive = false
OMKCursorMode = false
OMKCurrentMode = "default"
OMKCursorX = 0
OMKCursorY = 0
OMKCursorZ = 0
OMKHelpText = ""
OMKDrawAllSpringArrows = true
SelectionBoxColor = 0xFF00FF00 --ldcGreen might not be defined yet

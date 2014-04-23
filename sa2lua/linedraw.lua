function EnableLineDrawingIfNecessary()
	if IsPlayerValid() then
		if trace then print("EnableLineDrawingIfNecessary called") end
		if readInteger(hookcmd) == nil then
			if trace then print("EnableLineDrawingIfNecessary enabling object spawning") end
			EnableObjectSpawning()
		end
		if not IsLineDrawingEnabled() then
			if trace then print("EnableLineDrawingIfNecessary enabling line drawing") end
			LDLineCodeAddr = allocateSharedMemory("DrawLine3DCode", 4096)
			LDLineListAddr = allocateSharedMemory("DrawLine3DList", 65536)
			readRegionFromFile("sa2lua/linedraw.bin", LDLineCodeAddr)
			CreateLineDrawingObject()
		else
			if FindObjectByName(0x01A5A258, "$Lua$DrawLine3D") == 0 then
				CreateLineDrawingObject()
			end
		end
	end
end

function CreateLineDrawingObject()
	SpawnObject(LDLineCodeAddr, "$Lua$DrawLine3D", 1, 1, true, 0,0,0,0,0,0,0,0,0,0)
	LDWaitingForObj = true
end

function IsLineDrawingEnabled()
	if LDLineCodeAddr == nil or LDLineListAddr == nil then
		LDWaitingForObj = false
		return false
	end
	if LDWaitingForObj then return true end
	if readString(readInteger(linedraw_objaddr + 0x44), 64) == "$Lua$DrawLine3D" then
		return readInteger(linedraw_objaddr) ~= linedraw_objaddr
	else
		return false
	end
end

function UpdateLineList()
	if not IsLineDrawingEnabled() then return end
	if trace then print("UpdateLineList called") end
	local count = 0
	local addr = LDLineListAddr+4
	for k,v in pairs(LDLineList) do
		writeFloat(addr, v.x1)
		writeFloat(addr+4, v.y1)
		writeFloat(addr+8, v.z1)
		writeFloat(addr+12, v.x2)
		writeFloat(addr+16, v.y2)
		writeFloat(addr+20, v.z2)
		writeInteger(addr+24, v.color)
		addr = addr + 28
		count = count + 1
	end
	for k,v in pairs(LDLineListTemp) do
		writeFloat(addr, v.x1)
		writeFloat(addr+4, v.y1)
		writeFloat(addr+8, v.z1)
		writeFloat(addr+12, v.x2)
		writeFloat(addr+16, v.y2)
		writeFloat(addr+20, v.z2)
		writeInteger(addr+24, v.color)
		addr = addr + 28
		count = count + 1
	end
	writeInteger(LDLineListAddr, count)
end

function DrawLineObjectCallback(addr)
	if trace then print("DrawLineObjectCallback called") end
	writeInteger(readInteger(addr + 0x38), LDLineListAddr)
	linedraw_objaddr = addr
	LDWaitingForObj = false
end

function DrawLine3DPerformRotation(line, axis1, axis2, ctr1, ctr2, angle)
	--Internal function used by DrawLine3D
	if angle ~= 0 then
		for i=1,2 do
			local x = line[axis1..tonumber(i)] - ctr1
			local y = line[axis2..tonumber(i)] - ctr2
			local th = math.rad(angle * (360 / 0x10000))
			line[axis1..tonumber(i)] = (x*math.cos(th) - y*math.sin(th)) + ctr1
			line[axis2..tonumber(i)] = (x*math.sin(th) + y*math.cos(th)) + ctr2
		end
	end
end

function DrawLine3D(identifier, x1, y1, z1, x2, y2, z2, color, temp)
	local line = {}
	line.x1 = x1
	line.y1 = y1
	line.z1 = z1
	line.x2 = x2
	line.y2 = y2
	line.z2 = z2
	
	DrawLine3DPerformRotation(line, "x", "z", LDRotateCtrX, LDRotateCtrZ, LDRotateY)
	DrawLine3DPerformRotation(line, "y", "z", LDRotateCtrY, LDRotateCtrZ, LDRotateX)
	DrawLine3DPerformRotation(line, "x", "y", LDRotateCtrX, LDRotateCtrY, LDRotateZ)
	
	line.color = color
	if temp then
		LDLineListTemp[identifier] = line
	else
		LDLineList[identifier] = line
	end
	--UpdateLineList()
end

function RemoveLine(identifier)
	LDLineList[identifier] = nil
	--UpdateLineList()
end

function ClearLines()
	LDLineList = {}
	LDLineListTemp = {}
	--UpdateLineList()
end

function DrawCube3D(identifier, x1, y1, z1, x2, y2, z2, color, temp)
--[[
	 -----+pt1
    /|   /|
   |----| |
   |/---|-|
pt2+----|/
]]

	-- Top edges
	DrawLine3D(identifier.."1",  x1, y1, z1, x1, y1, z2, color, temp)
	DrawLine3D(identifier.."2",  x1, y1, z2, x2, y1, z2, color, temp)
	DrawLine3D(identifier.."3",  x2, y1, z2, x2, y1, z1, color, temp)
	DrawLine3D(identifier.."4",  x2, y1, z1, x1, y1, z1, color, temp)
	
	-- Bottom edges
	DrawLine3D(identifier.."5",  x1, y2, z1, x1, y2, z2, color, temp)
	DrawLine3D(identifier.."6",  x1, y2, z2, x2, y2, z2, color, temp)
	DrawLine3D(identifier.."7",  x2, y2, z2, x2, y2, z1, color, temp)
	DrawLine3D(identifier.."8",  x2, y2, z1, x1, y2, z1, color, temp)
	
	-- Side edges
	DrawLine3D(identifier.."9",  x1, y1, z1, x1, y2, z1, color, temp)
	DrawLine3D(identifier.."10", x1, y1, z2, x1, y2, z2, color, temp)
	DrawLine3D(identifier.."11", x2, y1, z2, x2, y2, z2, color, temp)
	DrawLine3D(identifier.."12", x2, y1, z1, x2, y2, z1, color, temp)
end

function DrawCylinder3D(identifier, x, y, z, r, h, sides, color, temp)
	for i=0,sides-1 do
		local twopi = math.rad(360)
		local x1 = r*math.cos(i * twopi/sides) + x
		local z1 = r*math.sin(i * twopi/sides) + z
		local x2 = r*math.cos((i+1) * twopi/sides) + x
		local z2 = r*math.sin((i+1) * twopi/sides) + z
		DrawLine3D(identifier..tonumber(i).."b", x1, y-h/2, z1, x2, y-h/2, z2, color, temp) --bottom
		DrawLine3D(identifier..tonumber(i).."t", x1, y+h/2, z1, x2, y+h/2, z2, color, temp) --top
		DrawLine3D(identifier..tonumber(i).."s", x1, y-h/2, z1, x1, y+h/2, z1, color, temp) --side
	end
end

function RemoveCylinder(identifier, sides)
	for i=0,sides-1 do
		RemoveLine(identifier..tonumber(i).."b")
		RemoveLine(identifier..tonumber(i).."t")
		RemoveLine(identifier..tonumber(i).."s")
	end
end

function DrawCursor3D(identifier, x, y, z, r, color)
	DrawLine3D(identifier.."X", x-r, y, z, x+r, y, z, color, temp)
	DrawLine3D(identifier.."Y", x, y-r, z, x, y+r, z, color, temp)
	DrawLine3D(identifier.."Z", x, y, z-r, x, y, z+r, color, temp)
end

function RemoveCursor(identifier)
	RemoveLine(identifier.."X")
	RemoveLine(identifier.."Y")
	RemoveLine(identifier.."Z")
end

function RemoveCube(identifier)
	for i=1,12 do
		RemoveLine(identifier..tostring(i))
	end
end

function LDResetRotation()
	LDRotateX = 0 --units for these variables are BAMS
	LDRotateY = 0 --perform rotation in order Y, X, Z
	LDRotateZ = 0
	LDRotateCtrX = 0
	LDRotateCtrY = 0
	LDRotateCtrZ = 0
end

LDLineList = {}
LDLineListTemp = {}
LDLineListAddr = nil
LDLineCodeAddr = nil
LDWaitingForObj = false
LDResetRotation()

ldcBlack = 0xFF000000
ldcRed = 0xFFFF0000
ldcOrange = 0xFFFF8000
ldcYellow = 0xFFFFFF00
ldcGreen = 0xFF00FF00
ldcCyan = 0xFF00FFFF
ldcBlue = 0xFF0000FF
ldcPurple = 0xFF8000C0
ldcMagenta = 0xFFFF00FF
ldcWhite = 0xFFFFFFFF
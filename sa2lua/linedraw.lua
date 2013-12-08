function EnableLineDrawingIfNecessary()
	if trace then print("EnableLineDrawingIfNecessary called") end
	if readInteger(hookcmd) == nil then
		if trace then print("EnableLineDrawingIfNecessary enabling object spawning") end
		EnableObjectSpawning()
	end
	if not IsLineDrawingEnabled() then
		if trace then print("EnableLineDrawingIfNecessary enabling line drawing") end
		linecodeaddr = allocateSharedMemory("DrawLine3DCode", 4096)
		linelistaddr = allocateSharedMemory("DrawLine3DList", 65536)
		readRegionFromFile("sa2lua/linedraw.bin", linecodeaddr)
		SpawnObject(linecodeaddr, "$Lua$DrawLine3D", 1, 1, true, 0,0,0,0,0,0,0,0,0,0)
		waiting_for_linedraw_obj = true
	end
end

function IsLineDrawingEnabled()
	if linecodeaddr == nil or linelistaddr == nil then
		waiting_for_linedraw_obj = false
		return false
	end
	if waiting_for_linedraw_obj then return true end
	if readString(readInteger(linedraw_objaddr + 0x44), 64) == "$Lua$DrawLine3D" then
		return readInteger(linedraw_objaddr) ~= linedraw_objaddr
	else
		return false
	end
end

function UpdateLineList()
	if trace then print("UpdateLineList called") end
	EnableLineDrawingIfNecessary()
	local count = 0
	local addr = linelistaddr+4
	for k,v in pairs(linelist) do
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
	writeInteger(linelistaddr, count)
end

function DrawLineObjectCallback(addr)
	if trace then print("DrawLineObjectCallback called") end
	writeInteger(readInteger(addr + 0x38), linelistaddr)
	linedraw_objaddr = addr
	waiting_for_linedraw_obj = false
end

function DrawLine3D(identifier, x1, y1, z1, x2, y2, z2, color)
	local line = {}
	line.x1 = x1
	line.y1 = y1
	line.z1 = z1
	line.x2 = x2
	line.y2 = y2
	line.z2 = z2
	line.color = color
	linelist[identifier] = line
	UpdateLineList()
end

function RemoveLine(identifier)
	linelist[identifier] = nil
	UpdateLineList()
end

function ClearLines()
	linelist = {}
	UpdateLineList()
end

function DrawCube3D(identifier, x1, y1, z1, x2, y2, z2, color)
--[[
	 -----+pt1
    /|   /|
   |----| |
   |/---|-|
pt2+----|/
]]

	-- Top edges
	DrawLine3D(identifier.."1",  x1, y1, z1, x1, y1, z2, color)
	DrawLine3D(identifier.."2",  x1, y1, z2, x2, y1, z2, color)
	DrawLine3D(identifier.."3",  x2, y1, z2, x2, y1, z1, color)
	DrawLine3D(identifier.."4",  x2, y1, z1, x1, y1, z1, color)
	
	-- Bottom edges
	DrawLine3D(identifier.."5",  x1, y2, z1, x1, y2, z2, color)
	DrawLine3D(identifier.."6",  x1, y2, z2, x2, y2, z2, color)
	DrawLine3D(identifier.."7",  x2, y2, z2, x2, y2, z1, color)
	DrawLine3D(identifier.."8",  x2, y2, z1, x1, y2, z1, color)
	
	-- Side edges
	DrawLine3D(identifier.."9",  x1, y1, z1, x1, y2, z1, color)
	DrawLine3D(identifier.."10", x1, y1, z2, x1, y2, z2, color)
	DrawLine3D(identifier.."11", x2, y1, z2, x2, y2, z2, color)
	DrawLine3D(identifier.."12", x2, y1, z1, x2, y2, z1, color)
end

function RemoveCube(identifier)
	for i=1,12 do
		RemoveLine(identifier..tostring(i))
	end
end

linelist = {}
linelistaddr = nil
linecodeaddr = nil
waiting_for_linedraw_obj = false

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
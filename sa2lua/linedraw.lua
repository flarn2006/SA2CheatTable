function EnableLineDrawingIfNecessary()
	if readInteger(hookcmd) == nil then
		EnableObjectSpawning()
	end
	if readInteger(readInteger(linedraw_objaddr)) == nil then
		linecodeaddr = allocateSharedMemory("DrawLine3DCode", 4096)
		linelistaddr = allocateSharedMemory("DrawLine3DList", 65536)
		readRegionFromFile("sa2lua/linedraw.bin", linecodeaddr)
		SpawnObject(linecodeaddr, "$Lua$DrawLine3D", 1, 2, true, 0,0,0,0,0,0,0,0,0,0)
	end
end

function UpdateLineList()
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
	writeInteger(readInteger(addr + 0x38), linelistaddr)
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
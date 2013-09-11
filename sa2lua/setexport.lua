function SETNumToByteStr(value, numbytes)
	local bytes = {}
	for i = 0, numbytes-1 do
		local byte = Bitwise.bw_and(value, 0xFF * 0x100^i)
		byte = byte / 0x100^i
		table.insert(bytes, byte)
	end
	return string.char(unpack(bytes)):reverse()
end

function SETWriteHeader(file, objcount)
	file:write(SETNumToByteStr(objcount, 4))
	for i = 1, 28 do
		file:write(string.char(0))
	end
end

function SETFindObjectType(routine, objlist)
	-- use GetStageObjList() for objlist
	for i,v in ipairs(objlist) do
		if v.routine == routine then return i end
	end
	return nil
end

function SETWriteEntry(file, addr, routine)
	local typeid = SETFindObjectType(routine, GetStageObjList())
	if typeid == nil then return false end
	
	local rx = readInteger(GetObjData1(addr, 0x08))
	local ry = readInteger(GetObjData1(addr, 0x0C))
	local rz = readInteger(GetObjData1(addr, 0x10))
	local px = readInteger(GetObjData1(addr, 0x14))
	local py = readInteger(GetObjData1(addr, 0x18))
	local pz = readInteger(GetObjData1(addr, 0x1C))
	local sx = readInteger(GetObjData1(addr, 0x20))
	local sy = readInteger(GetObjData1(addr, 0x24))
	local sz = readInteger(GetObjData1(addr, 0x28))
	
	file:write(SETNumToByteStr(typeid-1, 2))
	file:write(SETNumToByteStr(rx, 2))
	file:write(SETNumToByteStr(ry, 2))
	file:write(SETNumToByteStr(rz, 2))
	file:write(SETNumToByteStr(px, 4))
	file:write(SETNumToByteStr(py, 4))
	file:write(SETNumToByteStr(pz, 4))
	file:write(SETNumToByteStr(sx, 4))
	file:write(SETNumToByteStr(sy, 4))
	file:write(SETNumToByteStr(sz, 4))
	
	return true
end

function SETWriteFile(file, objects)
	local count = 0
	for i,v in ipairs(ol_spawned) do
		if SETFindObjectType(v.routine, GetStageObjList()) ~= nil then count = count + 1 end
	end
	SETWriteHeader(file, count)
	for i,v in ipairs(ol_spawned) do
		SETWriteEntry(file, v.addr, v.routine)
	end
	return count
end
	
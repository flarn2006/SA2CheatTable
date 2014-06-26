--[[function FindObjectByName(objlist, name)
	local originalAddr = readInteger(objlist)
	local addr = originalAddr
	if readInteger(addr) == nil then return nil end
	local limit = 5000
	repeat
		if addr == nil then return nil end
		if readString(readInteger(addr + 0x44), 64) == name then
			return addr
		end
		addr = readInteger(addr + 4)
		limit = limit - 1
	until addr == originalAddr or limit == 0
	return 0
end]]--

function FindObjectByName(objlist, name)
	if allObjects[objlist] == nil then return nil end
	if #allObjects[objlist] == 0 then return nil end
	for i,v in ipairs(allObjects[objlist]) do
		if v.name == name then
			return obj
		end
	end
	return {}
end

function CheckForObjectWithName(objlist, name)
	local result = FindObjectByName(objlist, name)
	if result == nil then return nil end
	return #result ~= 0
end

function GenerateObjData(addr, listnum)
	if readInteger(addr) == nil then return nil end
	local objdata = {}
	
	objdata.address = addr
	objdata.routine = readInteger(addr + 0x10)
	objdata.name = readString(readInteger(addr + 0x44), 64)
	objdata.list = listnum
	objdata.flags = 15 --for SpawnFromObjData
	
	if readInteger(GetObjData1(addr, 0)) ~= nil then
		objdata.rx = readInteger(GetObjData1(addr, 0x8))
		objdata.ry = readInteger(GetObjData1(addr, 0xC))
		objdata.rz = readInteger(GetObjData1(addr, 0x10))
		objdata.px = readFloat(GetObjData1(addr, 0x14))
		objdata.py = readFloat(GetObjData1(addr, 0x18))
		objdata.pz = readFloat(GetObjData1(addr, 0x1C))
		objdata.sx = readFloat(GetObjData1(addr, 0x20))
		objdata.sy = readFloat(GetObjData1(addr, 0x24))
		objdata.sz = readFloat(GetObjData1(addr, 0x28))
	end
	
	return objdata
end

function UpdateObjFromData(objdata)
	local addr = objdata.address
	if readInteger(GetObjData1(addr, 0)) ~= nil then
		writeInteger(GetObjData1(addr, 0x8), objdata.rx)
		writeInteger(GetObjData1(addr, 0xC), objdata.ry)
		writeInteger(GetObjData1(addr, 0x10), objdata.rz)
		writeFloat(GetObjData1(addr, 0x14), objdata.px)
		writeFloat(GetObjData1(addr, 0x18), objdata.py)
		writeFloat(GetObjData1(addr, 0x1C), objdata.pz)
		writeFloat(GetObjData1(addr, 0x20), objdata.sx)
		writeFloat(GetObjData1(addr, 0x24), objdata.sy)
		writeFloat(GetObjData1(addr, 0x28), objdata.sz)
	end
end
		

function EnumerateObjects(listnum)
	local found = {}
	
	local originalAddr = readInteger(0x1A5A254 + 4 * listnum)
	local addr = originalAddr
	if readInteger(addr) == nil or not IsPlayerValid() then return nil end
	local limit = 5000
	repeat
		if addr == nil then return nil end
		table.insert(found, GenerateObjData(addr, listnum))
		addr = readInteger(addr + 4)
		limit = limit - 1
	until addr == originalAddr or limit == 0
	
	return found
end

function UpdateObjectListRecords()
	for i=0,6 do
		allObjects[i] = EnumerateObjects(i) or {}
	end
	selObj = GenerateObjData(objaddr)
end

allObjects = {}
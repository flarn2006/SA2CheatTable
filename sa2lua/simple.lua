-- I'm still not quite sure how best to do this.
-- The point is to create an easier interface for manipulating objects through Lua code.

function GetObjectList(listnum)
	local tbl = {}
	local start = readInteger(0x1A5A254 + 4*listnum)
	local addr = start
	
	repeat
		table.insert(tbl, addr)
		addr = readInteger(addr + 0x04)
	until addr == start or addr == nil
	
	return tbl
end

function GetObjectInfo(addr)
	local obj = {}
	obj.addr = addr
	obj.name = readString(addr + 0x44, 64)
	obj.mainrt = readInteger(addr + 0x10)
	obj.disprt = readInteger(addr + 0x14)
	obj.data1 = readInteger(addr + 0x34)
	obj.data2 = readInteger(addr + 0x40)
	if obj.data1 ~= 0 then
		obj.action = readBytes(obj.data1, 1, false)
		obj.rx = readInteger(obj.data1 + 0x08)
		obj.ry = readInteger(obj.data1 + 0x0C)
		obj.rz = readInteger(obj.data1 + 0x10)
		obj.px = readFloat(obj.data1 + 0x14)
		obj.py = readFloat(obj.data1 + 0x18)
		obj.pz = readFloat(obj.data1 + 0x1C)
	end
	return obj
end

function UpdateObject(obj)
	writeInteger(obj.addr + 0x10, obj.mainrt)
	writeInteger(obj.addr + 0x14, obj.disprt)
	if obj.data1 ~= 0 then
		writeBytes(obj.data1, obj.action)
		writeInteger(obj.data1 + 0x08, obj.rx)
		writeInteger(obj.data1 + 0x0C, obj.ry)
		writeInteger(obj.data1 + 0x10, obj.rz)
		writeFloat(obj.data1 + 0x14, obj.px)
		writeFloat(obj.data1 + 0x18, obj.py)
		writeFloat(obj.data1 + 0x1C, obj.pz)
	end
end
function SaveObjectList()
	local objlist = readInteger(0x1DDE268)
	local count = readInteger(objlist)
	objlist = readInteger(objlist + 0x04)
	
	local stage = readBytes(0x1934B70, 1, false)
	local file = io.open("objlist"..stage..".csv", "w+")
	file:write("name,flags,list,routine\n")
	
	for i=0,count-1 do
		local name = readString(readInteger(objlist + 0x0C), 64)
		local flags = readBytes(objlist, 1, false)
		local list = readBytes(objlist + 0x01, 1, false)
		local routine = readInteger(objlist + 0x08)
		if name == nil then name = "???" end
		file:write(name..","..num2hex(flags)..","..num2hex(list)..","..num2hex(routine).."\n")
		objlist = objlist + 0x10
	end
	
	file:close()
end
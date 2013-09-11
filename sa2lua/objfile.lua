function ReadSpawnListFromFile(file)
	local list = {}
	local cols = {}
	local req_cols = {"name", "routine", "flags", "list", "xpos", "ypos", "zpos",
		"xrot", "yrot", "zrot", "xscl", "yscl", "zscl"}
	local noerror = true
	local line1 = file:read()
	for i,v in ipairs(line1:split(",")) do
		cols[string.lower(v)] = i
	end
	for i,v in ipairs(req_cols) do
		if cols[v] == nil then
			messageDialog("Required column "..v.." is missing!", mtError, mbOK)
			noerror = false
			break
		end
	end
	while noerror do
		local line = file:read()
		if line == nil then break end -- check for eof
		local objdata = {}
		local linesplit = line:split(",")
		objdata.name = linesplit[cols["name"]]
		objdata.routine = tonumber(linesplit[cols["routine"]], 16)
		objdata.flags = tonumber(linesplit[cols["flags"]], 16)
		objdata.list = tonumber(linesplit[cols["list"]], 16)
		objdata.px = tonumber(linesplit[cols["xpos"]])
		objdata.py = tonumber(linesplit[cols["ypos"]])
		objdata.pz = tonumber(linesplit[cols["zpos"]])
		objdata.rx = tonumber(linesplit[cols["xrot"]], 16)
		objdata.ry = tonumber(linesplit[cols["yrot"]], 16)
		objdata.rz = tonumber(linesplit[cols["zrot"]], 16)
		objdata.sx = tonumber(linesplit[cols["xscl"]])
		objdata.sy = tonumber(linesplit[cols["yscl"]])
		objdata.sz = tonumber(linesplit[cols["zscl"]])
		table.insert(list, objdata)
	end
	return list
end

function WriteSpawnedObjListToFile(file)
	local count = 0
	file:write("name,routine,flags,list,xpos,ypos,zpos,xrot,yrot,zrot,xscl,yscl,zscl\n")
	for i,v in ipairs(ol_spawned) do
		local line = ""
		line = line..v.name..","
		line = line..num2hex(v.routine)..","
		line = line..num2hex(v.flags)..","
		line = line..num2hex(v.list)..","
		line = line..readFloat(GetObjData1(v.addr, 0x14))..","
		line = line..readFloat(GetObjData1(v.addr, 0x18))..","
		line = line..readFloat(GetObjData1(v.addr, 0x1C))..","
		line = line..num2hex(readInteger(GetObjData1(v.addr, 0x08)))..","
		line = line..num2hex(readInteger(GetObjData1(v.addr, 0x0C)))..","
		line = line..num2hex(readInteger(GetObjData1(v.addr, 0x10)))..","
		line = line..readFloat(GetObjData1(v.addr, 0x20))..","
		line = line..readFloat(GetObjData1(v.addr, 0x24))..","
		line = line..readFloat(GetObjData1(v.addr, 0x28))
		file:write(line.."\n")
		count = count + 1
	end
	return count
end

function SpawnNextObject()
	if #spawnqueue > 0 then
		SpawnFromObjData(spawnqueue[1])
		table.remove(spawnqueue, 1)
	end
end

function SpawnFromObjData(objdata)
	SpawnObject(objdata.routine, objdata.name, objdata.flags, objdata.list, true,
		objdata.px, objdata.py, objdata.pz, objdata.rx, objdata.ry, objdata.rz,
		objdata.sx, objdata.sy, objdata.sz, 0)
end

function LoadObjListClick(sender)
	local file = io.open(openDialog_execute(SpawnedObjList_OpenDlg))
	if file ~= nil then
		spawnqueue = ReadSpawnListFromFile(file)
		file:close()
		SpawnNextObject()
	end
end

function SaveObjListClick(sender)
	local count
	local filename = openDialog_execute(SpawnedObjList_SaveDlg)
	local file
	if SpawnedObjList_SaveDlg.FilterIndex == 2 then
		file = io.open(filename, "w+b")
	else
		file = io.open(filename, "w+")
	end
	if file ~= nil then
		if SpawnedObjList_SaveDlg.FilterIndex == 2 then
			count = SETWriteFile(file, ol_spawned)
		else
			count = WriteSpawnedObjListToFile(file)
		end
		file:close()
		messageDialog("Wrote "..count.." objects", mtInformation, mbOK)
	end
end

-- CE 6.3 broke this function
function openDialog_execute(od)
	if od.execute() then
		return od.Filename
	else
		return nil
	end
end

spawnqueue = {}
dofile("sa2lua/setexport.lua")
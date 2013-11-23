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
		if spawnqueueRotationMode > 0 then
			local angle_bams = spawnqueueAngleBAMS
			local angle = angle_bams * (math.pi / 0x8000)
			angle = -angle
			local x = spawnqueue[1].px
			local z = spawnqueue[1].pz
			spawnqueue[1].px = x*math.cos(angle) - z*math.sin(angle)
			spawnqueue[1].pz = x*math.sin(angle) + z*math.cos(angle)
			if spawnqueueRotationMode == 1 then
				spawnqueue[1].ry = (spawnqueue[1].ry + angle_bams) % 0x100000000
			end
		end
		
		spawnqueue[1].px = spawnqueue[1].px + spawnqueueOffsetX
		spawnqueue[1].py = spawnqueue[1].py + spawnqueueOffsetY
		spawnqueue[1].pz = spawnqueue[1].pz + spawnqueueOffsetZ
		
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
		
		if SpawnedObjList_spawnRelative.Checked then
			spawnqueueOffsetX = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
			spawnqueueOffsetY = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
			spawnqueueOffsetZ = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
			spawnqueueRotationMode = SpawnedObjList_spawnRotated.State
			spawnqueueAngleBAMS = readInteger(GetObjData1(readInteger(0x1DEA6E0), 0x0C))
		else
			spawnqueueOffsetX = 0
			spawnqueueOffsetY = 0
			spawnqueueOffsetZ = 0
			spawnqueueRotationMode = 0
			spawnqueueAngleBAMS = 0
		end
		
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

function spawnRelativeChange(sender)
	SpawnedObjList_spawnRotated.Enabled = SpawnedObjList_spawnRelative.Checked
end

function spawnRotatedChange(sender)
	
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
spawnqueueOffsetX = 0
spawnqueueOffsetY = 0
spawnqueueOffsetZ = 0
spawnqueueRotationMode = 0
spawnqueueAngleBAMS = 0
dofile("sa2lua/setexport.lua")
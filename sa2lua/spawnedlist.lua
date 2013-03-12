function ShowSpawnedObjListClick(sender)
	form_show(SpawnedObjList)
end

function ClearSpawnedObjectsClick(sender)
	local result = messageDialog("Really delete all spawned objects?", mtWarning, mbYes, mbNo)
	if result == mrYes then
		for i,v in ipairs(ol_spawned) do
			writeInteger(v.addr + 0x10, 0x46F720)
		end
		ol_spawned = {}
		OLUpdateList()
	end
end

function SpawnedObjListDblClick(sender)
	local index = listview_getItemIndex(sender) + 1
	if index >= 0 then
		objaddr = tonumber(ol_spawned[index].addr)
		OCUpdateControls()
		form_show(ObjectChain)
	end
end

function OLAddObject(addr, routine, flags, list)
	local obj = {}
	obj.name = readString(readInteger(addr + 0x44), 64)
	obj.addr = addr
	local player = readInteger(0x1DEA6E0)
	obj.x = readFloat(GetObjData1(addr, 0x14))
	obj.y = readFloat(GetObjData1(addr, 0x18))
	obj.z = readFloat(GetObjData1(addr, 0x1C))
	obj.routine = routine
	obj.flags = flags
	obj.list = list
	table.insert(ol_spawned, obj)
	OLUpdateList()
end

function OLRemoveObject(addr)
	for i,v in ipairs(ol_spawned) do
		if v.addr == addr then
			table.remove(ol_spawned, i)
			break
		end
	end
	OLUpdateList()
end

function OLUpdateList()
	local lvitems = listview_getItems(SpawnedObjList_ObjList)
	listitems_clear(lvitems)
	for i,v in ipairs(ol_spawned) do
		local item = listitems_add(lvitems)
		local cols = listitem_getSubItems(item)
		listitem_setCaption(item, i)
		strings_add(cols, v.name)
		strings_add(cols, num2hex(v.addr))
		strings_add(cols, "---")
		v.listitem = item
	end
	OLUpdateDistances()
end

function OLCheckForDeletedObjects()
	local shouldUpdate = false
	for i,v in ipairs(ol_spawned) do
		if readString(readInteger(v.addr + 0x44), 64) ~= v.name
		or readInteger(GetObjData1(v.addr, 0)) == nil then
			table.remove(ol_spawned, i)
			shouldUpdate = true
		end
	end
	if shouldUpdate then OLUpdateList() end
end

function OLUpdateDistances()
	local player = readInteger(0x1DEA6E0)
	if readInteger(GetObjData1(player, 0)) == nil then
		-- Level has been unloaded; spawned objects no longer exist
		ol_spawned = {}
	end
	for i,v in ipairs(ol_spawned) do
		local cols = listitem_getSubItems(v.listitem)
		if readFloat(GetObjData1(v.addr, 0x14)) ~= nil then
			local dx = math.abs(readFloat(GetObjData1(v.addr, 0x14)) - readFloat(GetObjData1(player, 0x14)))
			local dy = math.abs(readFloat(GetObjData1(v.addr, 0x18)) - readFloat(GetObjData1(player, 0x18)))
			local dz = math.abs(readFloat(GetObjData1(v.addr, 0x1C)) - readFloat(GetObjData1(player, 0x1C)))
			local dist = math.sqrt(dx^2 + dy^2 + dz^2)
			strings_setString(cols, 2, string.format("%.1f", dist))
		else
			strings_setString(cols, 2, "---")
		end
	end
end

ol_spawned = {}
OLUpdateList()
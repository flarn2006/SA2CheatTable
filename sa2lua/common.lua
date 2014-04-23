dofile("sa2lua/bitwise.lua")

function num2hex(num)
	-- Adapted from http://snipplr.com/view/13086/number-to-hex/
	if num ~= nil then
		local hexstr = '0123456789ABCDEF'
		local s = ''
		if num < 0 then
			num = 0xFFFFFFFF - (math.abs(num) - 1)
		end
		while num > 0 do
			local mod = math.fmod(num, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			num = math.floor(num / 16)
		end
		if s == '' then s = '0' end
		return s
	else
		return ""
	end
end

function OpenCaptionAddress(sender)
	local addr = tonumber(control_getCaption(sender), 16)
	if addr ~= nil then
		local memview = getMemoryViewForm()
		local hexview = memoryview_getHexadecimalView(memview)
		hexadecimalview_setTopAddress(hexview, addr)
		form_show(memview)
	end
end

function LoadBinaryFile(filename, address)
	local file = io.open(filename, "rb")
	if file == nil then
		print("Error opening file "..filename.."!")
		return nil
	end
	local data = file:read("*all")
	local length = string.len(data)
	file:close()
	for i=1,length do
		local addr = address - 1 + i
		writeBytes(addr, string.byte(data, i))
	end
	return length
end

--[[function AllocateString(str)
	local len = string.len(str)
	local allocNew = false
	local str_addr = nil
	if str_alloc_addr == nil then
		allocNew = true
	else
		-- check if we have enough memory allocated
		for i=0,len do -- remember the \0 at the end...that's why it's not len-1
			if readBytes(str_alloc_addr+i, 1, false) == nil then
				allocNew = true
				break
			end
		end
	end
	if allocNew then str_alloc_addr = allocateSharedMemory("AllocateString", 4096) end
	str_addr = str_alloc_addr
	writeString(str_addr, str)
	writeBytes(str_addr + len, 0)
	str_alloc_addr = str_addr + len + 1
	fullAccess(str_addr, len + 1) -- couldn't hurt, just in case
	return str_addr
end]]

function alloc(size, name)
	if name == nil then name = "luatemp" end
	autoAssemble([[
alloc(]]..name..[[, ]]..size..[[)
registersymbol(]]..name..[[)
]])
	return getAddress("luatemp")
end 

function AllocateString(str)
	local addr = allocateSharedMemory("String:"..str, string.len(str) + 1)
	writeString(addr, str)
	--print("Wrote \""..str.."\" to 0x"..num2hex(addr))
	return addr
end

function string:split(delimiter)
	-- This function was written by krsk9999 on Stack Overflow
	-- http://stackoverflow.com/questions/1426954/split-string-in-lua
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

function SetAndFreezeValue(desc, val)
	local alist = getAddressList()
	local mrec = addresslist_getMemoryRecordByDescription(alist, desc)
	memoryrecord_freeze(mrec, 0)
	memoryrecord_setValue(mrec, val)
end

function UnfreezeValue(desc)
	local alist = getAddressList()
	local mrec = addresslist_getMemoryRecordByDescription(alist, desc)
	memoryrecord_unfreeze(mrec)
end

function UpdateTimer(sender)
	local controls = readInteger(0x1A529EC)
	OLCheckForDeletedObjects()
	OLUpdateDistances()
	if checkbox_getState(ObjectChain_AutoUpdate) == cbUnchecked then
		OCUpdateControls()
	end
	CheckForSpawnedObject()
	CheckForFCReturnValue()
	UpdateCollisionButtonCaption()
	if controls ~= nil then
		if Bitwise.bw_and(controls, 0x08080000) then
			local addr = readInteger(readInteger(0x1DEA6E0))
			if addr ~= nil then
				writeBytes(readInteger(addr + 0x34), 58)
			end
		end
	end
	
	UpdateObjectListRecords()
	EnableLineDrawingIfNecessary()
	
	if IsLineDrawingEnabled() and IsPlayerValid() then
		local x = tonumber(control_getCaption(SpawnObjectDlg_OffX))
		local y = tonumber(control_getCaption(SpawnObjectDlg_OffY))
		local z = tonumber(control_getCaption(SpawnObjectDlg_OffZ))
		local notZero = (x ~= 0 or y ~= 0 or z ~= 0)
		
		if x ~= nil and y ~= nil and z ~= nil then
			x = x + readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
			y = y + readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
			z = z + readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
			if notZero then
				DrawCursor3D("OffsetCursor", x, y, z, 5, ldcRed)
			else
				RemoveCursor("OffsetCursor")
			end
		end
	end
	
	UpdateControllerState()
	HandleControllerState()
	OMKDrawObjects()
	UpdateLineList()
	LDLineListTemp = {}
end

function IsPlayerValid()
	local addr = readInteger(readInteger(0x1DEA6E0))
	return (addr ~= nil)
end

function readWord(addr)
	local lo = readBytes(addr, 1, false)
	local hi = readBytes(addr+1, 1, false)
	return 256*hi + lo
end

function round(num, idp)
	-- Taken from http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function debugger_onBreakpoint()
	local func = BreakpointCallbackTbl[EIP]
	if func == nil then
		return 0
	else
		return func()
	end
end

-- Check for the correct version of Cheat Engine

if getCEVersion() < 6.3 then
	local msg = [[You are currently running Cheat Engine ]]..tostring(getCEVersion())..[[.
	
	If you do not upgrade to Cheat Engine 6.3, certain functionality (object list load/save) will not work correctly. If you do not need this functionality, you may disregard this message.
	
	Open the Cheat Engine download page now?]]
	
	if messageDialog(msg, mtExclamation, mbYes, mbNo) == mrYes then
		shellExecute("http://www.cheatengine.org/downloads.php")
	end
end

BreakpointCallbackTbl = {[0x47BD30] = LTHHookTriggered}
str_alloc_addr = nil
controller = {}

dofile("sa2lua/objenum.lua")
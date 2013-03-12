function ShowCallFuncClick(sender)
	control_setCaption(CallFunc_EAX, "00000000")
	control_setCaption(CallFunc_EBX, "00000000")
	control_setCaption(CallFunc_ECX, "00000000")
	control_setCaption(CallFunc_EDX, "00000000")
	control_setCaption(CallFunc_ESI, "00000000")
	control_setCaption(CallFunc_EDI, "00000000")
	fc_stack = {}
	LoadFunctionList()
	FCUpdateControls()
	form_show(CallFunc)
end

function LoadFunctionList()
	fc_funclist = {}
	for s in io.lines("sa2lua/functions.csv") do
		local parsed = s:split(",")
		local addr
		local func = {}
		if #parsed >= 9 then
			addr = tonumber(parsed[1], 16)
			func.name = parsed[2]
			func.eax = parsed[3]
			func.ebx = parsed[4]
			func.ecx = parsed[5]
			func.edx = parsed[6]
			func.esi = parsed[7]
			func.edi = parsed[8]
			func.stack = parsed[9]
			fc_funclist[addr] = func
		end
	end
	local lbitems = combobox_getItems(CallFunc_Function)
	strings_clear(lbitems)
	for k,v in pairs(fc_funclist) do
		strings_add(lbitems, v.name)
	end
end

function StackAddClick(sender)
	local val = 0
	local str = control_getCaption(CallFunc_StackVal)
	local fmt = combobox_getItemIndex(CallFunc_StackType)
	if (fmt == 0) then
		val = tonumber(str, 16)
		str = "0x"..string.upper(str)
	elseif (fmt == 1) then
		val = tonumber(str)
	elseif (fmt == 2) then
		val = allocateSharedMemory(string.len(str) + 1)
		writeString(val, str)
		str = "\""..str.."\""
	end
	if val ~= nil then
		local item = {}
		item.val = val
		item.str = str
		item.fmt = fmt
		table.insert(fc_stack, item)
		control_setCaption(CallFunc_StackVal, "")
	else
		messageDialog("Invalid input!", mtError, mbOK)
	end
	FCUpdateControls()
end

function StackRemClick(sender)
	local index = listbox_getItemIndex(CallFunc_StackList) + 1
	table.remove(fc_stack, index)
	FCUpdateControls()
end

function CallClick(sender)
	local eax = tonumber(control_getCaption(CallFunc_EAX), 16)
	local ebx = tonumber(control_getCaption(CallFunc_EBX), 16)
	local ecx = tonumber(control_getCaption(CallFunc_ECX), 16)
	local edx = tonumber(control_getCaption(CallFunc_EDX), 16)
	local esi = tonumber(control_getCaption(CallFunc_ESI), 16)
	local edi = tonumber(control_getCaption(CallFunc_EDI), 16)
	local stcount = #fc_stack
	writeInteger(hookcmd, 2)
	writeInteger(hookcmd + 0x04, GetSelectedFuncAddr())
	writeInteger(hookcmd + 0x08, eax)
	writeInteger(hookcmd + 0x0C, ebx)
	writeInteger(hookcmd + 0x10, ecx)
	writeInteger(hookcmd + 0x14, edx)
	writeInteger(hookcmd + 0x18, esi)
	writeInteger(hookcmd + 0x1C, edi)
	writeInteger(hookcmd + 0x20, stcount)
	for i,v in ipairs(fc_stack) do
		local addr = hookcmd + 0x24 + 4*(i-1)
		WriteStackValue(addr, v)
	end
	local msg = "Return value (EAX) will be shown when available.\n"
	msg = msg.."If you call another function, this one will not be called.\n"
	msg = msg.."Call another function anyway?\n"
	msg = msg.."Click Ignore to not call another function or show return value."
	local result = messageDialog(msg, mtQuestion, mbYes, mbNo, mbIgnore)
	if result ~= mrYes then
		form_close(CallFunc)
	end
	if result == mrNo then
		fc_show_retval = true
	end
end

function CheckForFCReturnValue()
	if readInteger(hookcmd) == -2 then
		writeInteger(hookcmd, 0)
		if fc_show_retval then
			local eax = readInteger(hookcmd + 0x08)
			msg = "Return value in EAX = "..num2hex(eax)
			messageDialog(msg, mtInformation, mbOK)
			fc_show_retval = false
		end
	end
end

function GetSelectedFuncAddr()
	local str = control_getCaption(CallFunc_Function)
	for k,v in pairs(fc_funclist) do
		if v.name == str then
			return k
		end
	end
	return tonumber(str, 16)
end

function WriteStackValue(addr, stackval)
	if stackval.fmt == 1 then
		writeFloat(addr, stackval.val)
	else
		writeInteger(addr, stackval.val)
	end
end

function FCUpdateControls()
	local lbitems = listbox_getItems(CallFunc_StackList)
	strings_clear(lbitems)
	for i,v in ipairs(fc_stack) do
		strings_add(lbitems, v.str)
	end
	local selfunc = fc_funclist[GetSelectedFuncAddr()]
	if selfunc ~= nil then
		control_setCaption(CallFunc_LblEAX, EmptyStrIfNil(selfunc.eax))
		control_setCaption(CallFunc_LblEBX, EmptyStrIfNil(selfunc.ebx))
		control_setCaption(CallFunc_LblECX, EmptyStrIfNil(selfunc.ecx))
		control_setCaption(CallFunc_LblEDX, EmptyStrIfNil(selfunc.edx))
		control_setCaption(CallFunc_LblESI, EmptyStrIfNil(selfunc.esi))
		control_setCaption(CallFunc_LblEDI, EmptyStrIfNil(selfunc.edi))
		control_setCaption(CallFunc_StackLbl, "Req: "..EmptyStrIfNil(selfunc.stack))
	else
		control_setCaption(CallFunc_LblEAX, "???")
		control_setCaption(CallFunc_LblEBX, "???")
		control_setCaption(CallFunc_LblECX, "???")
		control_setCaption(CallFunc_LblEDX, "???")
		control_setCaption(CallFunc_LblESI, "???")
		control_setCaption(CallFunc_LblEDI, "???")
		control_setCaption(CallFunc_StackLbl, "Stack parameters unknown.")
	end
end

function EmptyStrIfNil(str)
	if str == nil then return "" else return str end
end

control_setEnabled(CallFunc_Call, false)
LoadFunctionList()
fc_stack = {}
fc_show_retval = false
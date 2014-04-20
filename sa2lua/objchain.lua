function ShowObjectChainClick(sender)
	form_show(ObjectChain)
end

function OCUpdateControls()
	local valid = false
	control_setCaption(ObjectChain_Address, num2hex(objaddr))
	if readInteger(objaddr) ~= nil then valid = true end
	if valid then
		local temp = readString(readInteger(objaddr + 0x44), 64)
		control_setCaption(ObjectChain_ObjectName, temp)
		temp = readFloat(GetObjData1(objaddr, 0x14))
		control_setCaption(ObjectChain_ObjPosX, temp)
		temp = readFloat(GetObjData1(objaddr, 0x18))
		control_setCaption(ObjectChain_ObjPosY, temp)
		temp = readFloat(GetObjData1(objaddr, 0x1C))
		control_setCaption(ObjectChain_ObjPosZ, temp)
		temp = readInteger(GetObjData1(objaddr, 0x08))
		control_setCaption(ObjectChain_ObjRotX, num2hex(temp))
		temp = readInteger(GetObjData1(objaddr, 0x0C))
		control_setCaption(ObjectChain_ObjRotY, num2hex(temp))
		temp = readInteger(GetObjData1(objaddr, 0x10))
		control_setCaption(ObjectChain_ObjRotZ, num2hex(temp))
		if ocscalehex then
			temp = readInteger(GetObjData1(objaddr, 0x20))
			control_setCaption(ObjectChain_ObjSclX, num2hex(temp))
			temp = readInteger(GetObjData1(objaddr, 0x24))
			control_setCaption(ObjectChain_ObjSclY, num2hex(temp))
			temp = readInteger(GetObjData1(objaddr, 0x28))
			control_setCaption(ObjectChain_ObjSclZ, num2hex(temp))
			control_setCaption(ObjectChain_SclType, "Hex")
		else
			temp = readFloat(GetObjData1(objaddr, 0x20))
			control_setCaption(ObjectChain_ObjSclX, temp)
			temp = readFloat(GetObjData1(objaddr, 0x24))
			control_setCaption(ObjectChain_ObjSclY, temp)
			temp = readFloat(GetObjData1(objaddr, 0x28))
			control_setCaption(ObjectChain_ObjSclZ, temp)
			control_setCaption(ObjectChain_SclType, "Float")
		end
		temp = readInteger(objaddr + 0x34)
		control_setCaption(AdvObjParams_ObjData1, num2hex(temp))
		temp = readInteger(objaddr + 0x38)
		control_setCaption(AdvObjParams_ObjData2, num2hex(temp))
		temp = readInteger(objaddr + 0x3C)
		control_setCaption(AdvObjParams_ObjData3, num2hex(temp))
		temp = readInteger(objaddr + 0x40)
		control_setCaption(AdvObjParams_ObjData4, num2hex(temp))
		temp = readInteger(objaddr + 0x10)
		control_setCaption(AdvObjParams_ObjMainRt, num2hex(temp))
		temp = readInteger(objaddr + 0x14)
		control_setCaption(AdvObjParams_ObjDispRt, num2hex(temp))
		temp = readBytes(GetObjData1(objaddr, 0), 1, false)
		control_setCaption(AdvObjParams_ObjAction, num2hex(temp))
		if UpdateObjectSelCube ~= nil then UpdateObjectSelCube() end
	else
		control_setCaption(ObjectChain_Address, "Click Reset")
		control_setCaption(ObjectChain_ObjectName, "")
		control_setCaption(ObjectChain_ObjPosX, "")
		control_setCaption(ObjectChain_ObjPosY, "")
		control_setCaption(ObjectChain_ObjPosZ, "")
		control_setCaption(ObjectChain_ObjRotX, "")
		control_setCaption(ObjectChain_ObjRotY, "")
		control_setCaption(ObjectChain_ObjRotZ, "")
		control_setCaption(ObjectChain_ObjSclX, "")
		control_setCaption(ObjectChain_ObjSclY, "")
		control_setCaption(ObjectChain_ObjSclZ, "")
		control_setCaption(AdvObjParams_ObjData1, "")
		control_setCaption(AdvObjParams_ObjData2, "")
		control_setCaption(AdvObjParams_ObjMainRt, "")
		control_setCaption(AdvObjParams_ObjDispRt, "")
		control_setCaption(AdvObjParams_ObjAction, "")
	end
end

function SclTypeClick(sender)
	ocscalehex = not ocscalehex
	OCUpdateControls()
end

function PrevObject()
	local addr = readInteger(objaddr)
	if addr ~= nil then objaddr = addr end
	OCUpdateControls()
	UpdateRemote()
end

function NextObject()
	local addr = readInteger(objaddr + 0x04)
	if addr ~= nil then objaddr = addr end
	OCUpdateControls()
	UpdateRemote()
end

function GetObjData1(object, offset)
	local addr = object
	if addr == nil then return nil end
	addr = readInteger(addr + 0x34)
	if addr == nil then return nil end
	return (addr + offset)
end

function ObjToMeClick(sender)
	local x = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
	local y = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
	local z = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
	writeFloat(GetObjData1(objaddr, 0x14), x)
	writeFloat(GetObjData1(objaddr, 0x18), y)
	writeFloat(GetObjData1(objaddr, 0x1C), z)
	OCUpdateControls()
end

function MeToObjClick(sender)
	local x = readFloat(GetObjData1(objaddr, 0x14))
	local y = readFloat(GetObjData1(objaddr, 0x18))
	local z = readFloat(GetObjData1(objaddr, 0x1C))
	local oldaddr = ocaddr
	writeFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14), x)
	writeFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18), y)
	writeFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C), z)
	OCUpdateControls()
end

function ObjSetValuesClick(sender)
	local px = tonumber(control_getCaption(ObjectChain_ObjPosX))
	local py = tonumber(control_getCaption(ObjectChain_ObjPosY))
	local pz = tonumber(control_getCaption(ObjectChain_ObjPosZ))
	local rx = tonumber(control_getCaption(ObjectChain_ObjRotX), 16)
	local ry = tonumber(control_getCaption(ObjectChain_ObjRotY), 16)
	local rz = tonumber(control_getCaption(ObjectChain_ObjRotZ), 16)
	writeFloat(GetObjData1(objaddr, 0x14), px)
	writeFloat(GetObjData1(objaddr, 0x18), py)
	writeFloat(GetObjData1(objaddr, 0x1C), pz)
	writeInteger(GetObjData1(objaddr, 0x08), rx)
	writeInteger(GetObjData1(objaddr, 0x0C), ry)
	writeInteger(GetObjData1(objaddr, 0x10), rz)
	if ocscalehex then
		local sx = tonumber(control_getCaption(ObjectChain_ObjSclX), 16)
		local sy = tonumber(control_getCaption(ObjectChain_ObjSclY), 16)
		local sz = tonumber(control_getCaption(ObjectChain_ObjSclZ), 16)
		writeInteger(GetObjData1(objaddr, 0x20), sx)
		writeInteger(GetObjData1(objaddr, 0x24), sy)
		writeInteger(GetObjData1(objaddr, 0x28), sz)
	else
		local sx = tonumber(control_getCaption(ObjectChain_ObjSclX))
		local sy = tonumber(control_getCaption(ObjectChain_ObjSclY))
		local sz = tonumber(control_getCaption(ObjectChain_ObjSclZ))
		writeFloat(GetObjData1(objaddr, 0x20), sx)
		writeFloat(GetObjData1(objaddr, 0x24), sy)
		writeFloat(GetObjData1(objaddr, 0x28), sz)
	end
    OCUpdateControls()
end

function RotZeroClick(sender)
	writeInteger(GetObjData1(objaddr, 0x08), 0)
	writeInteger(GetObjData1(objaddr, 0x0C), 0)
	writeInteger(GetObjData1(objaddr, 0x10), 0)
	OCUpdateControls()
end

function SclOneClick(sender)
	writeFloat(GetObjData1(objaddr, 0x20), 1.0)
	writeFloat(GetObjData1(objaddr, 0x24), 1.0)
	writeFloat(GetObjData1(objaddr, 0x28), 1.0)
	OCUpdateControls()
end

function BaseAddressClick(sender)
	local sel = radiogroup_getItemIndex(ObjectChain_BaseAddress)
	ocaddr = 0x1A5A254 + sel * 4
    objaddr = readInteger(ocaddr)
    OCUpdateControls()
end

function ResetAddress()
	objaddr = readInteger(ocaddr)
	OCUpdateControls()
end

function ObjSetAdvValuesClick(sender)
	local rmain = tonumber(control_getCaption(AdvObjParams_ObjMainRt), 16)
	local rdisp = tonumber(control_getCaption(AdvObjParams_ObjDispRt), 16)
	local action = tonumber(control_getCaption(AdvObjParams_ObjAction), 16)
	writeInteger(objaddr + 0x10, rmain)
	writeInteger(objaddr + 0x14, rdisp)
	writeBytes(GetObjData1(objaddr, 0), action)
end

function ShowAdvObjParamsClick(sender)
	form_show(AdvObjParams)
end

function ShowFindDialogClick(sender)
	form_show(FindObjDlg)
end

function FindObjectClick(sender)
	local start = objaddr
	local back = false
	local query = control_getCaption(FindObjDlg_SearchQuery)
	if component_getTag(sender) == 0 then back = true end
	local count = 0
	while true do
		local oldaddr = objaddr
		if back then PrevObject() else NextObject() end
		local name = readString(readInteger(objaddr + 0x44), 64)
		local match = false
		if checkbox_getState(FindObjDlg_FindWholeObjName) == cbChecked then
			if name == query then match = true end
		else
			if string.find(name, query, 1, true) ~= nil then match = true end
		end
		if match then break end
		if objaddr == start or objaddr == oldaddr then
			messageDialog("No matching objects found.", mtInformation, mbOK)
			break
		end
		count = count + 1
		if count > 1000 then
			messageDialog("Infinite loop protection triggered!", mtError, mbOK)
			break
		end
	end
	OCUpdateControls()
end

function DeleteObjClick(sender)
	writeInteger(objaddr + 0x10, 0x46F720)
	OLRemoveObject(objaddr)
	OCUpdateControls()
end

function AutoUpdateChange(sender)
	local enable = checkbox_getState(ObjectChain_AutoUpdate) == cbChecked
	control_setEnabled(ObjectChain_ObjPosX, enable)
	control_setEnabled(ObjectChain_ObjPosY, enable)
	control_setEnabled(ObjectChain_ObjPosZ, enable)
	control_setEnabled(ObjectChain_ObjRotX, enable)
	control_setEnabled(ObjectChain_ObjRotY, enable)
	control_setEnabled(ObjectChain_ObjRotZ, enable)
	control_setEnabled(ObjectChain_ObjSclX, enable)
	control_setEnabled(ObjectChain_ObjSclY, enable)
	control_setEnabled(ObjectChain_ObjSclZ, enable)
end

-- Initialization

endobjaddr = 0
ocaddr = 0x1A5A254
ocscalehex = false
radiogroup_setItemIndex(ObjectChain_BaseAddress, 0)
OCUpdateControls()

timer_setEnabled(ObjectChain_Update, true)
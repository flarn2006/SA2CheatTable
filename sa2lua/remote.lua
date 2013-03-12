function ShowRemote()
	form_show(Remote)
end

function UpdateRemote()
	local btns = {Remote_Btn1, Remote_Btn2, Remote_Btn3, Remote_Btn4, Remote_Btn5, Remote_Btn6, Remote_Btn7, Remote_Btn8}
	
	SetRemoteText("Unrecognized")
	
	for i,v in ipairs(btns) do
		control_setEnabled(v, false)
		control_setCaption(v, "-")
	end
	
	rmtobjaddr = objaddr
	SetRemoteButtons()
	
	local count = #remote_btnfunc
	for i=1,count do
		control_setEnabled(btns[i], true)
		control_setCaption(btns[i], remote_btntext[i])
	end
end

function RemoteButtonClick(sender)
	local index = component_getTag(sender)
	local func = remote_btnfunc[index]
	func()
end

function SetRemoteText(text)
	control_setCaption(Remote_TextBox, text)
end

function RmtSetScaleToMe()
	local x = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x14))
	local y = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x18))
	local z = readFloat(GetObjData1(readInteger(0x1DEA6E0), 0x1C))
	writeFloat(GetObjData1(rmtobjaddr, 0x20), x)
	writeFloat(GetObjData1(rmtobjaddr, 0x24), y)
	writeFloat(GetObjData1(rmtobjaddr, 0x28), z)
end

function RmtAddActionBtn(text, action)
	local funcstr = "writeBytes(GetObjData1(rmtobjaddr, 0x00), "..tostring(action)..")"
	local func = loadstring(funcstr)
	table.insert(remote_btntext, text)
	table.insert(remote_btnfunc, func)
end

function SetRemoteButtons()
	local rt = readInteger(rmtobjaddr + 0x10) -- main routine
	remote_btntext = {}
	remote_btnfunc = {}
	
	if rt == 0x6D50F0 then -- ROCKET
		SetRemoteText("Rocket")
		table.insert(remote_btntext, "Set Target to Me")
		table.insert(remote_btnfunc, RmtSetScaleToMe)
	elseif rt == 0x6BE2E0 then -- MSGER (Omochao)
		SetRemoteText("Omochao")
		RmtAddActionBtn("Self Destruct", 3)
		RmtAddActionBtn("\"Discipline\"", 4)
		RmtAddActionBtn("Bug Me", 6)
		RmtAddActionBtn("Disable", 8)
	elseif rt == 0x6DBEB0 then -- BUNCHIN (Weight)
		SetRemoteText("Weight")
		table.insert(remote_btntext, "(Un)Freeze")
		table.insert(remote_btnfunc, function()
			local sbf = readBytes(GetObjData1(rmtobjaddr, 0x01), 1, false)
			if Bitwise.bw_and(sbf, 0x04) > 0 then sbf = sbf - 0x04 else sbf = sbf + 0x04 end
			writeBytes(GetObjData1(rmtobjaddr, 0x01), sbf)
		end)
	end
end

remote_btntext = {}
remote_btnfunc = {}
rmtobjaddr = objaddr
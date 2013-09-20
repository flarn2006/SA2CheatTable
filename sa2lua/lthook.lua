function LTHEnabledClick(sender)
	LTHHookEnabled = (checkbox_getState(sender) == cbChecked)
	if LTHHookEnabled then
		debugProcess()
		debug_setBreakpoint(0x47BD30)
	else
		debug_removeBreakpoint(0x47BD30)
	end
end

function LTHPauseClick(sender)
	LTHPause = (checkbox_getState(sender) == cbChecked)
end

function LTHTextureFileBtnClick(sender)
	LTHReplaceTexFile = (checkbox_getState(sender) == cbChecked)
end

function LTHMakeNonSolidClick(sender)
	LTHMakeNonSolid = (checkbox_getState(sender) == cbChecked)
end

function LTHReplaceModelClick(sender)
	LTHReplaceModel = (checkbox_getState(sender) == cbChecked)
end

function LTHHookTriggered()
	local ltaddr = 0x1DDA3C0
	if LTHHookEnabled then
		if LTHReplaceTexFile then
			local tfn = control_getCaption(LTHookConfig_LTHTextureFileName)
			local addr = AllocateString(tfn)
			writeInteger(ltaddr + 0x18, addr)
		end
		
		if LTHMakeNonSolid then
			local count = readWord(ltaddr)
			local pcol = readInteger(ltaddr + 0x10)
			for i=0,count-1 do
				local addr = pcol + 0x20*i + 0x1C
				local val = readInteger(addr)
				if val ~= nil then
					val = Bitwise.bw_and(val, 0xFFFFFFFE)
					writeInteger(addr, val)
				end
			end
		end
		
		if LTHPause then
			return 0
		else
			debug_continueFromBreakpoint()
			return 1
		end
	else
		return 0
	end
end

function ShowLTHCfgClick(sender)
	form_show(LTHookConfig)
end

LTHHookEnabled = false
LTHReplaceTexFile = false
LTHMakeNonSolid = false
LTHReplaceModel = false
LTHPause = false
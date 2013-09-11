debugProcess()
debug_setBreakpoint(0x44C350)

function debugger_onBreakpoint()
	print(readString(ECX) .. " : " .. num2hex(EDX));
	debug_continueFromBreakpoint(co_run)
	return 1
end
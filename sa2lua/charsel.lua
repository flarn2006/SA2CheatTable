function ShowCharSelectClick(sender)
	form_show(CharSelect)
end

function SelectCharClick(sender)
	local charload = {0x716E00, 0x740EB0, 0x728110, 0x717360, 0x740C50, 0x728460, 0x74CF00, 0x73C220, 0x7170E0, 0x717640, 0x7288B0, 0x728B60, 0x741110, 0x7412F0}
	local p1addr = {0x43D652, 0x43D664, 0x43D677, 0x43D68A, 0x43D69C, 0x43D6AC, 0x43D6BC, 0x43D6CE}
	local p2addr = {0x43D6FC, 0x43D70D, 0x43D71F, 0x43D731, 0x43D743, 0x43D753, 0x43D762, 0x43D773}
	local bossaddr = {0x4C710C, 0x4C7119, 0x6193E1, 0x6193EE, 0x62668D, 0x62669B, 0x64869D, 0x6486AB, 0x6486AB, 0x661CFD, 0x661D0B}
	local target = radiogroup_getItemIndex(CharSelect_SetCharFor)
	local tgtaddr = {}

	if target == 0 then --Player 1
		tgtaddr = p1addr
	elseif target == 1 then --Player 2
		tgtaddr = p2addr
	elseif target == 2 then --Boss
		tgtaddr = bossaddr
	end

	for i,v in ipairs(tgtaddr) do
		local char = listbox_getItemIndex(CharSelect_CharList)
		local val = (charload[char+1] - 4 - v)
		writeInteger(v, val)
	end
	
	BtnAltCharFixClick()

	form_hide(CharSelect)
end
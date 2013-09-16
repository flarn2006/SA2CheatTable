function LMLoadLevelList()
	stagelist = {}
	local lbitems = listbox_getItems(LevelMixer_LMLevelList)
	strings_clear(lbitems)
	for s in io.lines("sa2lua/stagelist.csv") do
		local ltbl = s:split(",")
		local tbl = {}
		tbl.name = ltbl[1]
		tbl.id = ltbl[2]
		tbl.chaoarea = ltbl[3]
		table.insert(stagelist, tbl)
		strings_add(lbitems, tbl.name)
	end
	control_setEnabled(LevelMixer_LMLevelList, true)
	control_setEnabled(LevelMixer_LMLoadObjects, true)
	control_setEnabled(LevelMixer_LMCombineLevels, true)
end

function ShowLevelMixerClick(sender)
	form_show(LevelMixer)
	LMLoadLevelList()
end

function LMLoadObjectsClick(sender)
	local id = stagelist[listbox_getItemIndex(LevelMixer_LMLevelList) + 1].id
	local ca = stagelist[listbox_getItemIndex(LevelMixer_LMLevelList) + 1].chaoarea
	writeInteger(0x1934B70, id)
	if ca ~= nil then writeInteger(0x134062C, ca) end
	writeBytes(0x1934BE0, 0x02)
end

function LMCombineLevelsClick(sender)
	local id = stagelist[listbox_getItemIndex(LevelMixer_LMLevelList) + 1].id
	local ca = stagelist[listbox_getItemIndex(LevelMixer_LMLevelList) + 1].chaoarea
	writeInteger(0x1934B70, id)
	if ca ~= nil then writeInteger(0x134062C, ca) end
	writeBytes(0x1934BE0, 0x03)
end

function LMLevelListDblClick(sender)
	local id = stagelist[listbox_getItemIndex(LevelMixer_LMLevelList) + 1].id
	SetAndFreezeValue("Current Level", id)
	showMessage("Level value frozen until you click OK")
	UnfreezeValue("Current Level")
end

control_setEnabled(LevelMixer_LMLevelList, false)
control_setEnabled(LevelMixer_LMLoadObjects, false)
control_setEnabled(LevelMixer_LMCombineLevels, false)
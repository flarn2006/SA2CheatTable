-- This file is run when the cheat table is first loaded.

-- Common stuff
dofile("sa2lua/common.lua")

-- Functions for the tweaks dialog
dofile("sa2lua/tweaks.lua")

-- Functions for saved locations dialog
dofile("sa2lua/teleport.lua")

-- Functions for object editing dialog
dofile("sa2lua/linedraw.lua")
dofile("sa2lua/objchain.lua")
dofile("sa2lua/objspawn.lua")
dofile("sa2lua/remote.lua")

-- Functions for the character select dialog
dofile("sa2lua/charsel.lua")

-- Functions for the Call Function dialog
dofile("sa2lua/callfunc.lua")

-- Functions for the Level Mixer dialog
dofile("sa2lua/lvlmixer.lua")

-- Functions for the Land Table hook
dofile("sa2lua/lthook.lua")

-- Live Edit Mode
dofile("sa2lua/objkeys.lua")

-- Physics Presets dialog
dofile("sa2lua/physpresets.lua")

-- Info Display
dofile("sa2lua/infodisp.lua")

-- Initialization

timer_setEnabled(ObjectChain_Update, true)
form_show(Tools)
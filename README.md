SA2 Cheat Table
===============

This is a cheat table for the PC version of Sonic Adventure 2 that allows for many different types of hacks.
It makes extensive use of Cheat Engine's Lua scripting engine to enable advanced hacks (like spawning items).

Download Cheat Engine at http://www.cheatengine.org/

Features Overview
-----------------

+ Many addresses in the address list, including
  - Basic variables like rings, lives, etc.
  - Chao data
  - Character physics parameters
  - And more!
+ Teleportation interface that saves locations in levels
+ Interface for viewing and editing the parameters of all loaded level objects
+ Allows you to spawn additional objects into the level, and save them to a file to be loaded later
  - Now exports in the game's native SET format, for use with [SETMerge](https://github.com/flarn2006/SETMerge)
  - This enables the additional objects to easily be added to the game data, making it permanent
+ Play as any character in any level, including in 2-player mode and boss battles
+ Load elements from multiple levels at once, to have (for example) Metal Harbor's water and sky in Meteor Herd
+ Directly call any function in the game's code (for advanced users)
+ Load levels with any level's textures (usually looks horrible, but in some cases [looks awesome](http://www.youtube.com/watch?v=8nTvmtM9KxI))
+ Skip logo screens by pressing Escape
+ Enable noclip mode (freely move character without being affected by gravity or walls) by pressing N
+ Many miscellaneous tweaks and hacks, including
  - Enable the test level and debug menu (debug menu can't actually be seen, but works)
  - Use Chao World character select on any level
  - Make levels load noticeably faster
  - Remove invisible walls from boss battles
  - And more!

Live Edit Mode
--------------
Live Edit Mode is a new feature that enables you to use the game pad to manipulate objects in-game (yes, I know I'm giving a lot of attention to that part!) with minimal window switching. It replaces the keyboard control feature, though the original keyboard controls still work when SA2 is active.

Once Live Edit Mode is activated (use the button on the Object Editing dialog) you can press Down on the D-pad to enable the cursor. Use the right analog stick and the triggers to move the cursor. When the cursor is activated, the closest object to the cursor will automatically be selected. You can also press Left to place whatever item you have highlighted in the object placement dialog, similar to the debug mode in the Genesis games. When the cursor is enabled, press Down again to turn it off and keep the selection.

With an object selected (and the cursor not active) you can also move and rotate the object using the controller. Hold Left to move the object around using the same controls as moving the cursor. Holding Up allows you to rotate the object. The triggers rotate around the Y (vertical) axis, and the right analog stick rotates around the X and Z (horizontal) axes. Keep in mind that some objects use the rotation values, especially the X and Z values, for different purposes. As a result, rotating these objects like this can cause different results, such as changing the rate at which it moves, or possibly crashing the game.

Another feature you may notice is that some previously invisible objects (such as collision boxes) are made visible. For example, in City Escape, you may see cyan boxes around rails, which I believe have something to do with giving bonus points for "tricks", and cylinders surrounding tree trunks which otherwise have no collision. If you've ever seen that "debug mode" Gameshark code for Sonic Adventure on the Dreamcast that makes all those white boxes appear, this serves a similar purpose.

If you quit and reload Cheat Engine without restarting SA2, and LEM's text display no longer functions, this is due to a limitation in Cheat Engine 6.3 and older. Upgrading to 6.4 should fix this.

Miscellaneous Tips
------------------

+ If you want to spawn an object in the air (like a balloon or a GUN Beetle robot), try spawning a movable cylinder, throwing it, and replacing it while it's in the air.
  - Alternatively, you can use the new "Offset from Player" section.
+ Double-click an object name in the spawning window to see help for its parameters. (only works with some objects)
+ Double-click on a level name in the Level Mixer dialog to freeze the level value. Then start any level and it will load that one instead.

Licensing
---------
This software is licensed under the [GNU General Public License v3.0](http://www.gnu.org/copyleft/gpl.html).

----------------------------------------------------------------------------------------------------------
*This could not have been made without the help of MainMemory from the Sonic Retro forums. Thank you! :-)*

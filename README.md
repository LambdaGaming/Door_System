# Door System
Simple door ownership system that works on any gamemode.

## Current Features:
<ul>
	<li>Own doors by looking at them and pressing F9. (Can now be customized through the spawn menu to any key.)</li>
	<li>Owned doors can be locked and unlocked with the keys.</li>
	<li>Locked doors can be forced open with the door ram.</li>
	<li>Admins can access a config in the door's menu to force an owner on that specific door.</li>
	<li>Specific owner restrictions can be configured in the doors_config.lua file.</li>
	<li>Owner restrictions will save in a JSON file for each map.</li>
	<li>Door owners can now set a custom name to their door that is visible to all players who look at the door.</li>
	<li>Support for owning whole rooms or buildings without having to manually own each individual door. (Server owners have to set this up manually, this doesn't support any maps out of the box.)</li>
	<li>Admins can force specific doors to lock when the map loads.</li>
</ul>

## Note:
If you use this on DarkRP you'll have to disable the built-in door system for that gamemode. They shouldn't conflict with each other code-wise but the HUD elements will overlap.

## Suggestions:
Suggestions are always appreciated but this is one of my more minor projects so I may take some small suggestions but probably not anything big.
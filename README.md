# Door System
Simple door ownership system that works on any gamemode.

## Current Features:
- Own doors by looking at them and pressing F9. (Can now be customized through the spawn menu to any key.)
- Owned doors can be locked and unlocked with the keys.
- Locked doors can be forced open with the door ram.
- Admins can access a config in the door's menu to force an owner on that specific door.
- Specific owner restrictions and gamemode configs can be configured in the doors_config.lua file.
- Owner restrictions will save in a JSON file for each map.
- Door owners can now set a custom name to their door that is visible to all players who look at the door.
- Support for owning whole rooms or buildings without having to manually own each individual door. (Server owners have to set this up manually, this doesn't support any maps out of the box.)
- Admins can force specific doors to lock when the map loads.
- Door owners can add other players as co-owners, allowing them to lock and unlock those doors.

## Notes:
- If you use this on DarkRP you'll have to disable the built-in door system for that gamemode. They shouldn't conflict with each other code-wise but the HUD elements will overlap.
- This is a low priority project for me, so you'll mostly see nothing but bug fixes and occasional small features. I'll still be reviewing all pull requests, though.

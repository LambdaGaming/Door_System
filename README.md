# Door System
Minimalistic door ownership system for Garry's Mod that works on any gamemode.

## Features
- Own doors by looking at them and pressing F9. (Can now be customized through the spawn menu to any key.)
- Owned doors can be locked and unlocked with the keys.
- Locked doors can be forced open with the door ram.
- Admins can force individual doors to have a specific owner, be tied to a group, or lock on map load.
- Specific owner restrictions and gamemode configs can be configured in the doors_config.lua file.
- Owner restrictions will save in a JSON file for each map.
- Door owners can set a custom name to their door that is visible to all players who look at the door.
- Door owners can add other players as co-owners, allowing them to lock and unlock those doors.
- Support for owning whole rooms or buildings without having to manually own each individual door. (Server owners have to set this up manually, this doesn't support any maps out of the box.)
- Hooks for various functions that allow developers to modify the addon's behavior.

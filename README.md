# Universal Door System
Minimalistic door ownership system for Garry's Mod that works on any gamemode. Please note however that no specific gamemode is supported out of the box, so if you want this system to work with a currency system for example, you will need to use the provided hooks to add that support yourself. See below and the [door_config.lua](lua/autorun/doors_config.lua) file for more info.

## Features
- Own doors by looking at them and pressing F9. (Can now be customized through the spawn menu to any key.)
- Owned doors can be locked and unlocked with the keys.
- Locked doors can be forced open with the door ram.
- Admins can force individual doors to have a specific owner, have ownership disabled entirely, be tied to a group, or lock on map load.
- Specific owner restrictions and other settings can be configured in the doors_config.lua file.
- Owner restrictions will save in a JSON file for each map.
- Door owners can set a custom name to their door that is visible to all players who look at the door.
- Door owners can add other players as co-owners, allowing them to lock and unlock those doors.
- Support for owning whole rooms or buildings without having to manually own each individual door. (Server owners have to set this up manually, this doesn't support any maps out of the box.)
- Hooks for various functions that allow developers to modify the addon's behavior.

## Hooks
|Name|Scope|Arguments|Description|
|----|-----|---------|-----------|
|DoorSystem_CanRam|Server|`Player` ply, `Entity` door|Called when a player attempts to use the door ram on a valid door. Return false to block the ram.|
|DoorSystem_CanBuyDoor|Server|`Player` ply, `Entity` door, `Number` price|Called when a player is about to purchase a door. Return false to block ownership.|
|DoorSystem_OnBuyDoor|Server|`Player` ply, `Entity` door, `Number` price|Called after a player purchases a door.|
|DoorSystem_OnSellDoor|Server|`Player` ply, `Entity` door|Called when a player sells a door.|

## Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)

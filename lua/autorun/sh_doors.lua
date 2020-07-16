
DoorTable = {
	Lock = {}
}
DoorCoOwners = {}
Door_System_Config = {}

Door_System_Config.AllowedDoors = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

local meta = FindMetaTable( "Player" )
function meta:CanUseDoor( index )
	if !DoorTable[index] then return false end
	return DoorRestrictions[DoorTable[index]].CheckFunction( self )
end
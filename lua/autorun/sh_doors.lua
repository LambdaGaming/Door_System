DoorTable = {
	Lock = {}
}
DoorCoOwners = {}
Door_System_Config = {}

function IsValidDoor( ent )
	local doors = {
		["prop_door"] = true,
		["prop_door_rotating"] = true,
		["func_door"] = true,
		["func_door_rotating"] = true
	}
	return doors[ent:GetClass()]
end

local meta = FindMetaTable( "Player" )
function meta:CanUseDoor( index )
	if !DoorTable[index] then return false end
	return DoorRestrictions[DoorTable[index]].CheckFunction( self )
end

DoorTable = {
	Lock = {}
}
DoorCoOwners = {}

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
	local tbl = DoorTable[index]
	if !tbl then return false end
	local res = DoorRestrictions[tbl]
	if !res then return false end
	return res.CheckFunction( self )
end

print( "Universal Door System v2.0.1 by OPGman successfully loaded." )

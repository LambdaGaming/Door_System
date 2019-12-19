
DoorTable = {}

local meta = FindMetaTable( "Player" )
function meta:CanUseDoor( index )
	if !DoorTable[index] then return false end
	return DoorRestrictions[DoorTable[index]].CheckFunction( self )
end
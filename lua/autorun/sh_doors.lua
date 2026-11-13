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
	return IsValid( ent ) and doors[ent:GetClass()]
end

local metaEnt = FindMetaTable( "Entity" )
function metaEnt:GetDoorOwner()
	return self:GetNWEntity( "DoorOwner" )
end

local meta = FindMetaTable( "Player" )
function meta:CanUseDoor( door )
	local owner = door:GetDoorOwner()
	local index = door:MapCreationID()
	if owner == self or ( DoorCoOwners[index] and table.HasValue( DoorCoOwners[index], self ) ) then
		return true
	end
	local tbl = DoorTable[index]
	if !tbl then return false end
	local res = DoorRestrictions[tbl]
	if !res then return false end
	return res.CheckFunction( self )
end

function meta:GetDoor()
	local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE
	local ent = self:GetEyeTrace().Entity
	if IsValidDoor( ent ) and self:GetPos():DistToSqr( ent:GetPos() ) < distance then
		return ent
	end
	return NULL
end

print( "Universal Door System v2.1.2 by OPGman successfully loaded." )

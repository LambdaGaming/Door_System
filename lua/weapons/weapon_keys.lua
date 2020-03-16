
AddCSLuaFile()

SWEP.PrintName = "Keys"
SWEP.Category = "Door System"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 2
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:ShouldDrawViewModel()
	return false
end

local allowed = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE

local function KeySound( ply, lock )
	ply:EmitSound( "npc/metropolice/gear"..math.random( 1, 6 )..".wav" )
	timer.Simple( 1, function()
		if lock then
			ply:EmitSound( "doors/door_latch1.wav" )
		else
			ply:EmitSound( "doors/door_latch3.wav" )
		end
	end )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	local index = tr:EntIndex()
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
    if allowed[tr:GetClass()] then
		if doorowner == self.Owner or ( DoorCoOwners[index] and table.HasValue( DoorCoOwners[index], self.Owner ) ) then
			if SERVER then
				tr:Fire( "lock", "", 0 )
				KeySound( self.Owner, true )
			end
		else
			if self.Owner:CanUseDoor( tr:EntIndex() ) then
				if SERVER then
					tr:Fire( "lock", "", 0 )
					KeySound( self.Owner, true )
				end
			else
				if SERVER then self.Owner:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" ) end
			end
		end
	end
    self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() then return end
	local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	local index = tr:EntIndex()
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
    if allowed[tr:GetClass()] then
		if doorowner == self.Owner or ( DoorCoOwners[index] and table.HasValue( DoorCoOwners[index], self.Owner ) ) then
			if SERVER then
				tr:Fire( "unlock", "", 0 )
				KeySound( self.Owner )
			end
		else
			if self.Owner:CanUseDoor( tr:EntIndex() ) then
				if SERVER then
					tr:Fire( "unlock", "", 0 )
					KeySound( self.Owner )
				end
			else
				if SERVER then self.Owner:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" ) end
			end
		end
	end
    self:SetNextPrimaryFire( CurTime() + 0.1 )
end
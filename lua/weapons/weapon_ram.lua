
AddCSLuaFile()

SWEP.PrintName = "Door Ram"
SWEP.Category = "Door System"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	self:SetHoldType( "rpg" )
end

local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE

local function ForceOpen( ply, door )
	ply:EmitSound( "physics/wood/wood_box_impact_hard3.wav" )
	timer.Simple( 1, function()
		door:Fire( "unlock", "", 0 )
		door:Fire( "open", "", 0 )
	end )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
	if DarkRP and IsValid( doorowner ) then
		if DOOR_CONFIG_REQUIRE_WARRANT and !doorowner.warranted then
			DarkRP.notify( self.Owner, 1, 6, "You need a warrant on the owner to force this door open." )
			return
		end
	end
    if Door_System_Config.AllowedDoors[tr:GetClass()] and SERVER then
		ForceOpen( self.Owner, tr )
	end
    self:SetNextPrimaryFire( CurTime() + 1 )
end
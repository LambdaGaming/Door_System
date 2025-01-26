AddCSLuaFile()

SWEP.PrintName = "Door Ram"
SWEP.Category = "Door System"
SWEP.Spawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "OPGman"
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
function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
	if IsValidDoor( tr ) then
		if hook.Run( "DoorSystem_CanRam", self.Owner, tr ) == false then return end
		ply:EmitSound( "physics/wood/wood_box_impact_hard3.wav" )
		ply:ViewPunch( Angle( -10, 0, 0 ) )
		timer.Simple( 1, function()
			door:Fire( "unlock", "", 0 )
			door:Fire( "open", "", 0 )
		end )
	end
	self:SetNextPrimaryFire( CurTime() + 1 )
end


AddCSLuaFile()

local mode = GetGlobalInt( "CurrentGamemode" )

SWEP.Category = "Door System"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 2

if mode == 2 or mode == 3 then
	SWEP.PrintName = "Combine Door Authorization"
	SWEP.ViewModel = "models/weapons/v_emptool.mdl"
	SWEP.WorldModel = "models/weapons/w_emptool.mdl"
	SWEP.OpenSound = "buttons/combine_button1.wav"
else
	SWEP.PrintName = "Door Ram"
	SWEP.ViewModel = "models/weapons/c_rpg.mdl"
	SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
	SWEP.OpenSound = "physics/wood/wood_box_impact_hard3.wav"
end

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if mode == 2 or mode == 3 then
		self:SetHoldType( "pistol" )
	else
		self:SetHoldType( "rpg" )
	end
end

local allowed = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE

local function ForceOpen( self, ply, door )
	ply:EmitSound( self.OpenSound )
	timer.Simple( 1, function()
		door:Fire( "unlock", "", 0 )
		door:Fire( "open", "", 0 )
	end )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace().Entity
	if !IsValid( tr ) then return end
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
    if allowed[tr:GetClass()] and SERVER then
		ForceOpen( self, self.Owner, tr )
	end
    self:SetNextPrimaryFire( CurTime() + 1 )
end

function SWEP:SecondaryAttack()
end

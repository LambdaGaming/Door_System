
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

local function Knock( ply, sound )
	ply:EmitSound( sound )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
    local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
    if allowed[tr:GetClass()] then
		if doorowner == self.Owner then
			tr:Fire( "Lock" )
			tr:EmitSound( "npc/metropolice/gear"..math.Rand( 1, 7 )..".wav" )
			self.Owner:AnimSetGestureSequence( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE )
		else
			Knock( self.Owner, "physics/wood/wood_crate_impact_hard2.wav" )
		end
	end
    self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
    local tr = self.Owner:GetEyeTrace().Entity
	local doorowner = tr:GetNWEntity( "DoorOwner" )
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > distance then return end
    if allowed[tr:GetClass()] then
		if doorowner == self.Owner then
			tr:Fire( "Unlock" )
			tr:EmitSound( "doors/latchunlocked1.wav" )
			self.Owner:AnimSetGestureSequence( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE )
		else
			Knock( self.Owner, "physics/wood/wood_crate_impact_hard2.wav" )
		end
	end
    self:SetNextSecondaryFire( CurTime() + 0.1 )
end
AddCSLuaFile()

SWEP.PrintName = "Keys"
SWEP.Category = "Door System"
SWEP.Spawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "OPGman"
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
	if !IsFirstTimePredicted() or CLIENT then return end
	local door = self.Owner:GetDoor()
	if !IsValid( door ) then return end
	if self.Owner:CanUseDoor( door ) then
		door:Fire( "lock", "", 0 )
		KeySound( self.Owner, true )
	else
		self.Owner:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" )
	end
    self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local door = self.Owner:GetDoor()
	if !IsValid( door ) then return end
	if self.Owner:CanUseDoor( door ) then
		door:Fire( "unlock", "", 0 )
		KeySound( self.Owner )
	else
		self.Owner:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" )
	end
    self:SetNextPrimaryFire( CurTime() + 0.1 )
end

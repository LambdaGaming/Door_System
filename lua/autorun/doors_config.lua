
DoorRestrictions = {} --Initializes the door restrictions table, don't touch
DoorGroups = {}

--[[
	Below are the configs for the door restrictions. Each table includes
	the name of the restriction and a boolean function to check if the player
	meets the requirements to lock/unlock the door.
]]

DoorRestrictions[1] = {
	Name = "Admin Only",
	CheckFunction = function( ply )
		return ply:IsAdmin() --Must return bool
	end
}

DoorRestrictions[2] = {
	Name = "Superadmin Only",
	CheckFunction = function( ply )
		return ply:IsSuperAdmin()
	end
}

--[[ DoorRestrictions[3] = { --Example for DarkRP jobs
	Name = "Police Only",
	CheckFunction = function( ply )
		local allowed = {
			[TEAM_MAYOR] = true,
			[TEAM_CHIEF] = true,
			[TEAM_POLICE] = true
		}
		return allowed[ply:Team()] --You can also use table.HasValue but this is more efficient
	end
} ]]


--[[
	Below are the configs for the door groups. With these you can
	tie doors together so that if a player buys one door, they will have
	access to a group of doors that are tied to the main door.
]]

--[[ DoorGroups["rp_rockford_v2b"] = { --Example group config
	[1022] = { --Parent door's entity index
		Name = "City Hall", --Name that appears on the door
		ChildDoors = { --Entity indexes of each child door
			1023,
			1024,
			1025
		}
	}
} ]]

--Misc Config

DOOR_CONFIG_PRICE = 30 --Price players pay for the doors (DarkRP only)

DOOR_CONFIG_CHARGE_EXTRA = false --Whether or not players should be charged for each door in a group (DarkRP only)

DOOR_CONFIG_REQUIRE_WARRANT = true --Whether or not cops need a warrant to force open doors with the battering ram (DarkRP only)

DOOR_CONFIG_GROUP_OVERRIDE = false --Whether or not a door that's part of a group should have it's owner overridden when buying the parent door

DOOR_CONFIG_MENU_COLOR = Color( 49, 53, 61, 200 ) --Color of the menu background

DOOR_CONFIG_BUTTON_COLOR = Color( 230, 93, 80, 255 ) --Color of the buttons

DOOR_CONFIG_NAME_COLOR = color_white --Color of the door name on the HUD

DOOR_CONFIG_TEXT_COLOR = Color( 255, 0, 0 ) --Color of the rest of the door info on the HUD

DOOR_CONFIG_BUTTON_TEXT_COLOR = color_white --Color of the text on the buttons

DOOR_CONFIG_DISTANCE = 100 --Max distance in hammer units away from a door where players can interact with it

DOOR_CONFIG_ALLOW_ADMIN = false --Whether or not admins should be able to edit door ownerships alongside superadmins
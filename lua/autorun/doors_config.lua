DoorRestrictions = {} --Initializes the door restrictions table, don't touch
DoorGroups = {}

--[[
	Below are the configs for the door restrictions. Each table includes
	the name of the restriction and a boolean function to check if the player
	meets the requirements to lock/unlock the door.
]]

timer.Simple( 5, function()
	if GetGlobalInt( "CurrentGamemode" ) == 1 then
		DoorRestrictions[2] = {
			Name = "Security Level 3 Access Required",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_ADMIN] = true,
					[TEAM_SECURITYBOSS] = true,
					[TEAM_SECURITY] = true,
					[TEAM_SERVICE] = true
				}
				return allowed[ply:Team()]
			end
		}

		DoorRestrictions[3] = {
			Name = "Service Personnel Only",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_ADMIN] = true,
					[TEAM_SERVICE] = true
				}
				return allowed[ply:Team()]
			end
		}

		DoorRestrictions[4] = {
			Name = "HECU Military Personnel Only",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_MARINEBOSS] = true,
					[TEAM_MARINE] = true,
					[TEAM_WEPBOSS] = true
				}
				return allowed[ply:Team()]
			end
		}

		DoorRestrictions[5] = {
			Name = "Security Level 2 Access Required",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_SURVEY] = true,
					[TEAM_SURVEYBOSS] = true,
					[TEAM_WEPBOSS] = true,
					[TEAM_BIO] = true,
					[TEAM_ADMIN] = true,
					[TEAM_SECURITY] = true,
					[TEAM_SECURITYBOSS] = true,
					[TEAM_TECH] = true,
					[TEAM_MEDIC] = true,
					[TEAM_SERVICE] = true
				}
				return allowed[ply:Team()]
			end
		}
	elseif GetGlobalInt( "CurrentGamemode" ) == 2 then
		DoorRestrictions[2] = {
			Name = "Overwatch Only",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_EARTHADMIN] = true,
					[TEAM_COMBINEELITE] = true,
					[TEAM_COMBINEGUARD] = true,
					[TEAM_COMBINESOLDIER] = true,
					[TEAM_METROCOP] = true,
					[TEAM_COMBINEGUARDSHOTGUN] = true,
					[TEAM_METROCOPMANHACK] = true,
					[TEAM_CREMATOR] = true
				}
				return allowed[ply:Team()]
			end
		}
	elseif GetGlobalInt( "CurrentGamemode" ) == 3 then
		DoorRestrictions[2] = {
			Name = "Overwatch Only",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_COMBINEELITE] = true,
					[TEAM_COMBINEGUARD] = true,
					[TEAM_COMBINESOLDIER] = true,
					[TEAM_COMBINEGUARDSHOTGUN] = true,
				}
				return allowed[ply:Team()]
			end
		}

		DoorRestrictions[3] = {
			Name = "Resistance Members Only",
			CheckFunction = function( ply )
				local allowed = {
					[TEAM_RESISTANCELEADER] = true,
					[TEAM_REBEL] = true,
					[TEAM_REBELMEDIC] = true
				}
				return allowed[ply:Team()]
			end
		}
	end
end )

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

DOOR_CONFIG_GROUP_OVERRIDE = false --Whether a door that's part of a group should have it's owner overridden or not when buying the parent door

DOOR_CONFIG_MENU_COLOR = Color( 49, 53, 61, 200 ) --Color of the menu background

DOOR_CONFIG_BUTTON_COLOR = Color( 230, 93, 80, 255 ) --Color of the buttons

DOOR_CONFIG_NAME_COLOR = color_black --Color of the door name on the HUD

DOOR_CONFIG_TEXT_COLOR = Color( 255, 0, 0 ) --Color of the rest of the door info on the HUD

DOOR_CONFIG_BUTTON_TEXT_COLOR = color_white --Color of the text on the buttons

DOOR_CONFIG_DISTANCE = 100 --Max distance in hammer units away from a door where players can interact with it

DOOR_CONFIG_ALLOW_ADMIN = false --Whether admins should be able to edit door ownerships alongside superadmins or not

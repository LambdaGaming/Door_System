
--[[
	Current Features:
	1. Simple door ownership through F2 menu
	2. Admin settings through F2 menu
	3. Support for restrictive ownership such as police only
	4. Support for saving ownership settings in json files for each map
]]

DoorRestrictions = {}

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

DoorRestrictions[3] = {
	Name = "Police Only",
	CheckFunction = function( ply )
		local allowed = {
			[TEAM_MAYOR] = true,
			[TEAM_CHIEF] = true,
			[TEAM_POLICE] = true
		}
		return allowed[ply:Team()]
	end
}

DOOR_CONFIG_MENU_COLOR = Color( 49, 53, 61, 200 ) --Color of the menu background

DOOR_CONFIG_BUTTON_COLOR = Color( 230, 93, 80, 255 ) --Color of the buttoms

DOOR_CONFIG_BUTTON_TEXT_COLOR = color_white --Color of the text on the buttons

DOOR_CONFIG_DISTANCE = 100 --Max distance in hammer units away from a door where players can interact with it

DOOR_CONFIG_ALLOW_ADMIN = false --Whether admins should be able to edit door ownerships alongside superadmins or not
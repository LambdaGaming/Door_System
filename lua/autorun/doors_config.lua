
--[[
	Planned Features:
	1. Simple door ownership through F2 menu *DONE*
	2. Support for multiple owners *NOT DONE*
	3. Support for restrictive ownership (police only, admin only, etc) *NOT DONE*
	4. Support for saving ownership settings in the server's SQL database *NOT DONE*
]]

DOOR_CONFIG_MENU_COLOR = Color( 49, 53, 61, 200 ) --Color of the menu background

DOOR_CONFIG_BUTTON_COLOR = Color( 230, 93, 80, 255 ) --Color of the buttoms

DOOR_CONFIG_BUTTON_TEXT_COLOR = color_white --Color of the text on the buttons

DOOR_CONFIG_DISTANCE = 100 --Max distance in hammer units away from a door where players can interact with it

DOOR_CONFIG_PRICE = 50 --Price of each door bought, only works on DarkRP

DOOR_CONFIG_SELL_PRICE = DOOR_CONFIG_PRICE * 0.75 --Money given back to the player after selling an owned door, currently set to 75% of the buy price, only works on DarkRP

DOOR_CONFIG_ALLOW_ADMIN = false --Whether admins should be able to edit door ownerships alongside superadmins or not
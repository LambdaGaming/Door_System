DoorRestrictions = {} --Initializes the door restrictions table, don't touch
DoorGroups = {}
DoorFunctions = {}
PlayerDoors = {}

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

DOOR_CONFIG_DOOR_GROUPS_ENABLED = true -- May not work with door amount at the moment
	DOOR_CONFIG_CHARGE_EXTRA = false --Whether or not players should be charged for each door in a group (DarkRP only)

DOOR_CONFIG_REQUIRE_WARRANT = true --Whether or not cops need a warrant to force open doors with the battering ram (DarkRP only)

DOOR_CONFIG_GROUP_OVERRIDE = false --Whether or not a door that's part of a group should have it's owner overridden when buying the parent door

DOOR_CONFIG_MENU_COLOR = Color( 49, 53, 61, 200 ) --Color of the menu background

DOOR_CONFIG_BUTTON_COLOR = Color( 230, 93, 80, 255 ) --Color of the buttons

DOOR_CONFIG_NAME_COLOR = color_white --Color of the door name on the HUD

DOOR_CONFIG_TEXT_COLOR = Color( 255, 0, 0 ) --Color of the rest of the door info on the HUD

DOOR_CONFIG_BUTTON_TEXT_COLOR = color_white --Color of the text on the buttons

DOOR_CONFIG_DISTANCE = 100 --Max distance in hammer units away from a door where players can interact with it

DOOR_CONFIG_ADMIN_RANKS = { --The ranks that have permission to edit door ownerships. CAPS COUNT
    ["superadmin"] = true,
    --["admin"] = true,
}

//Enter the entities you want admins always to have access to. For example, if you don't want users to manage "func_door"
DOOR_CONFIG_ADMIN_CAN_ALWAYS_CONFIGURE = { -- but you want admins to manage them, then put the entity class here.
	--["func_door"] = true,
	--["func_door_rotating"] = true,
}

DOOR_CONFIG_ALLOWED_DOOR_AMOUNT = 0 --How many doors the player may have at any time. If 0, you can own unlimited


//Choose one by removing or adding --
local function DOOR_CONFIG_PRICE_CHECK(ply, price) price = price or DOOR_CONFIG_PRICE return
	((ply:getDarkRPVar("money") or 0) >= price) //DarkRP
	--(ply:getChar():hasMoney(price))             //Nut Script
	--((ply:GetMoney() or 0) >= price)            //BaseWars
	--ply:SH_CanAffordStandard(price)             //SH Pointshop
	--ply:PS_HasPoints(price)                     //Pointshop
	--true                                        //Sandbox
end

//Choose one by removing or adding --
//For no currency, be sure to have -- in front of all currencies below
local function DOOR_CONFIG_PURCHASE(ply, price) price = price or DOOR_CONFIG_PRICE 
	ply:addMoney(-price)             //DarkRP
	--ply:getChar():takeMoney(price)   //Nut Script
	--ply:GiveMoney(-price)            //BaseWars
	--ply:SH_AddStandardPoints(-price) //SH Pointshop
	--ply:PS_TakePoints(price)         //Pointshop
end

local function OWN_MESSAGE(ply)
	if DOOR_CONFIG_ALLOWED_DOOR_AMOUNT > 0 then return DOOR_CONFIG_MESSAGES["Purchase Successful"] .. 
	" You have " .. tostring(DOOR_CONFIG_ALLOWED_DOOR_AMOUNT - PlayerDoors[ply]) .. " doors remaining." end
	return DOOR_CONFIG_MESSAGES["Purchase Successful"]
end

DOOR_CONFIG_COMMANDS = {
	["Sell All"] = "/sellalldoors"
}

DOOR_CONFIG_MESSAGES = {
	["Managed By Another Group"] = "This door is managed by a group and cannot be owned.",
	["Already Owned"] = "This door is already owned by someone else.",
	["Do Not Own"] = "You do not own this door.",
	["Cannot Afford"] = "You can't afford to buy this door.",
	["Purchase Successful"] = "You now own this door.",
	["Own Of All of Group"] = "You also now own all of the doors in the ", -- doorgroupName door group.
	["Override Successful"] = "Door ownership override successful.",
	["Sold From Group"] = "You have also sold all of the doors in the ", -- doorgroupName door group.
	["Sold All"] = "You have sold all of your doors.",
	["Ran Out of Doors"] = "You ran out of doors! Remove a door or remove all doors with " .. DOOR_CONFIG_COMMANDS["Sell All"],
	["No Doors Owned"] = "You do not own any doors.",
	["Door Sold"] = "You have sold this door.",
	["Door Locked"] = "This door is locked ..."
}


-------------------don't touch----------------------
DoorFunctions.DOOR_PRICE_CHECK = DOOR_CONFIG_PRICE_CHECK
DoorFunctions.DOOR_PURCHASE = DOOR_CONFIG_PURCHASE
DoorFunctions.OWN_MESSAGE = OWN_MESSAGE
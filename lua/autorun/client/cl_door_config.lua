Door_System_Config = {}

CreateClientConVar( "DoorKey", KEY_F9, true, false, "Key that you press to access the menu of a door." )

hook.Add( "PopulateToolMenu", "DoorConfig", function()
    spawnmenu.AddToolMenuOption( "Options", "Door System", "DoorSystem", "Config", "", "", function( panel )
		panel:AddControl( "Numpad", {
			Label = "Door Menu Key",
			Command = "DoorKey"
		} )
	end )
end )

Door_System_Config.AllowedDoors = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}


Door_System_Config.ShowDoorHealth = false -- Show the door health. 
		-- This is only useful if you have a door health addon like "Destructible Doors for Gmod!"
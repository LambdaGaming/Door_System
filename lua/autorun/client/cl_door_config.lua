
CreateClientConVar( "DoorKey", KEY_F9, true, false, "Key that you press to access the menu of a door." )

hook.Add( "PopulateToolMenu", "DoorConfig", function()
    spawnmenu.AddToolMenuOption( "Options", "Door System", "DoorSystem", "Config", "", "", function( panel )
		panel:AddControl( "Numpad", {
			Label = "Door Menu Key",
			Command = "DoorKey"
		} )
	end )
end )
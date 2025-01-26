CreateClientConVar( "DoorKey", KEY_F9, true, false, "Key that you press to access the menu of a door." )
CreateClientConVar( "ShowDoorHealth", "0", true, false, "Whether or not a door's health should appear on the HUD when looking at it." )

hook.Add( "PopulateToolMenu", "DoorConfig", function()
    spawnmenu.AddToolMenuOption( "Options", "Door System", "DoorSystem", "Config", "", "", function( panel )
		panel:AddControl( "Numpad", {
			Label = "Door Menu Key",
			Command = "DoorKey"
		} )
		panel:AddControl( "Checkbox", {
			Label = "Show Door Health",
			Command = "ShowDoorHealth"
		} )
	end )
end )

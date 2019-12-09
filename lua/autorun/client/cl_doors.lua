
surface.CreateFont( "DoorFont", {
	font = "Arial",
	size = 20,
	weight = 1000
} )

local allowed = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE

local OpenDoorMenuAdmin

local function OpenDoorConfig( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Admin Door Config" )
	menu:SetSize( 180, 300 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local backbutton = vgui.Create( "DButton", menu )
	backbutton:SetText( "Back" )
	backbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	backbutton:SetPos( 30, 30 )
	backbutton:SetSize( 150, 30 )
	backbutton:CenterHorizontal()
	backbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	backbutton.DoClick = function()
		menu:Close()
		OpenDoorMenuAdmin( ply, door )
	end
	local sellbutton = vgui.Create( "DButton", menu )
	sellbutton:SetText( "Remove Door Ownership" )
	sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	sellbutton:SetPos( 30, 70 )
	sellbutton:SetSize( 150, 30 )
	sellbutton:CenterHorizontal()
	sellbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	sellbutton.DoClick = function()
		net.Start( "UnownDoor" )
		net.WriteEntity( door )
		net.WriteBool( true )
		net.SendToServer()
		menu:Close()
	end
	ply.MenuOpen = true
end

OpenDoorMenuAdmin = function( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 180, 300 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	if !IsValid( door:GetNWEntity( "DoorOwner" ) ) then
		local buybutton = vgui.Create( "DButton", menu )
		buybutton:SetText( "Own Door" )
		buybutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		buybutton:SetPos( 30, 30 )
		buybutton:SetSize( 150, 30 )
		buybutton:CenterHorizontal()
		buybutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		buybutton.DoClick = function()
			net.Start( "OwnDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	else
		local sellbutton = vgui.Create( "DButton", menu )
		sellbutton:SetText( "Remove Door Ownership" )
		sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		sellbutton:SetPos( 30, 30 )
		sellbutton:SetSize( 150, 30 )
		sellbutton:CenterHorizontal()
		sellbutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		sellbutton.DoClick = function()
			net.Start( "UnownDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	end
	local configbutton = vgui.Create( "DButton", menu )
	configbutton:SetText( "Admin Door Config" )
	configbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	configbutton:SetPos( 30, 70 )
	configbutton:SetSize( 150, 30 )
	configbutton:CenterHorizontal()
	configbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	configbutton.DoClick = function()
		menu:Close()
		OpenDoorConfig( ply, door )
	end
	ply.MenuOpen = true
end

local function OpenDoorMenu( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 180, 300 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	if !IsValid( door:GetNWEntity( "DoorOwner" ) ) then
		local buybutton = vgui.Create( "DButton", menu )
		buybutton:SetText( "Own Door" )
		buybutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		buybutton:SetPos( 30, 30 )
		buybutton:SetSize( 150, 30 )
		buybutton:CenterHorizontal()
		buybutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		buybutton.DoClick = function()
			net.Start( "OwnDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	else
		local sellbutton = vgui.Create( "DButton", menu )
		sellbutton:SetText( "Unown Door" )
		sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		sellbutton:SetPos( 30, 30 )
		sellbutton:SetSize( 150, 30 )
		sellbutton:CenterHorizontal()
		sellbutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		sellbutton.DoClick = function()
			net.Start( "UnownDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	end
	ply.MenuOpen = true
end

hook.Add( "HUDPaint", "DoorHUD", function()
	local ply = LocalPlayer()
	local ent = ply:GetEyeTrace().Entity
	local color_red = Color( 255, 0, 0 )
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	if ply.MenuOpen then return end
	if IsValid( ent ) and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if IsValid( doorowner ) then
			draw.SimpleText( "Owner: "..doorowner:Nick(), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Owner: None", "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( "Press F2 for door options.", "DoorFont", ScrW() / 2, ScrH() / 2 + 20, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end )

hook.Add( "PlayerButtonDown", "DoorButtons", function( ply, button )
	local f2 = KEY_F2
	local ent = ply:GetEyeTrace().Entity
	if !IsFirstTimePredicted() or ply.MenuOpen then return end
	if IsValid( ent ) and button == f2 and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if ply:IsSuperAdmin() or ( ply:IsAdmin() and DOOR_CONFIG_ALLOW_ADMIN ) then
			OpenDoorMenuAdmin( ply, ent )
		else
			OpenDoorMenu( ply, ent )
		end
	end
end )
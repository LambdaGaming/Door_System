
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

local function OpenDoorMenu( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 150, 300 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 231, 76, 60, 150 ) )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local buybutton = vgui.Create( "DButton", menu )
	buybutton:SetText( "Buy Door" )
	buybutton:SetTextColor( Color( 255, 255, 255 ) )
	buybutton:SetPos( 30, 100 )
	buybutton:SetSize( 100, 30 )
	buybutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
	end
	buybutton.DoClick = function()
		net.Start( "BuyDoor" )
		net.WriteEntity( ply )
		net.WriteEntity( door )
		net.SendToServer()
		menu:Close()
	end
	local sellbutton = vgui.Create( "DButton", menu )
	sellbutton:SetText( "Sell Door" )
	sellbutton:SetTextColor( Color( 255, 255, 255 ) )
	sellbutton:SetPos( 30, 150 )
	sellbutton:SetSize( 100, 30 )
	sellbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
	end
	sellbutton.DoClick = function()
		net.Start( "SellDoor" )
		net.WriteEntity( ply )
		net.WriteEntity( door )
		net.SendToServer()
		menu:Close()
	end
	ply.MenuOpen = true
end

hook.Add( "HUDPaint", "DoorHUD", function()
	local ply = LocalPlayer()
	local ent = ply:GetEyeTrace().Entity
	local color_red = Color( 255, 0, 0 )
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local null = "[NULL Entity]"
	if ply.MenuOpen then return end
	if IsValid( ent ) and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if tostring( doorowner ) == null then
			draw.SimpleText( "Owner: "..doorowner:Name(), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Owner: None", "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( "Press F2 for door options.", "DoorFont", ScrW() / 2, ScrH() / 2 + 20, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end )

hook.Add( "PlayerButtonDown", "DoorButtons", function( ply, button )
	local f2 = KEY_F2
	local ent = ply:GetEyeTrace().Entity
	if ply.MenuOpen then return end
	if IsValid( ent ) and button == f2 and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		OpenDoorMenu( ply, door )
	end
end )
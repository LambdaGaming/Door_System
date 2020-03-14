
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

local function DS_Notify( ply, text )
	if DarkRP then
		net.Start( "DarkRPDoorChat" )
		net.WriteEntity( ply )
		net.WriteString( text )
		net.SendToServer()
		return
	end
	local textcolor1 = color_black
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Door System]: ", textcolor2, text )
end
net.Receive( "DS_Notify", function( len, ply )
	local text = net.ReadString()
	DS_Notify( ply, text )
end )

local function SetDoorName( ply, door )
	local owner = door:GetNWEntity( "DoorOwner" )
	if owner != ply then
		DS_Notify( ply, "You do not own this door." )
		return
	end
	local frame = vgui.Create( "DFrame" )
	frame:SetTitle( "Set Door Name" )
	frame:SetSize( 180, 70 )
	frame:Center()
	frame:MakePopup()
	frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( DOOR_CONFIG_MENU_COLOR, 255 ) )
	end
	local getname = vgui.Create( "DTextEntry", frame )
	getname:SetSize( 170, 20 )
	getname:SetPos( 5, 35 )
	getname.OnEnter = function( self )
		net.Start( "SetDoorName" )
		net.WriteEntity( door )
		net.WriteString( self:GetValue() )
		net.SendToServer()
		frame:Close()
	end
end

local function OpenDoorMenuAdmin( ply, door )
	local entindex = door:EntIndex()
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 220, 290 )
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
		buybutton:SetSize( 190, 30 )
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
		sellbutton:SetSize( 190, 30 )
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

	local namebutton = vgui.Create( "DButton", menu )
	namebutton:SetText( "Set Door Name" )
	namebutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	namebutton:SetPos( 30, 70 )
	namebutton:SetSize( 190, 30 )
	namebutton:CenterHorizontal()
	namebutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	namebutton.DoClick = function()
		SetDoorName( ply, door )
	end

	local adminlabel = Label( "Admin Settings", menu )
	adminlabel:SetSize( 190, 15 )
	adminlabel:SetPos( 70, 110 )

	local sellbutton = vgui.Create( "DButton", menu )
	sellbutton:SetText( "Force Remove Ownership" )
	sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	sellbutton:SetPos( 30, 130 )
	sellbutton:SetSize( 190, 30 )
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

	local restrictbutton = vgui.Create( "DButton", menu )
	if DoorTable[entindex] then
		restrictbutton:SetText( "Change Restriction" )
	else
		restrictbutton:SetText( "Add Restriction" )
	end
	restrictbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictbutton:SetPos( 30, 170 )
	restrictbutton:SetSize( 190, 30 )
	restrictbutton:CenterHorizontal()
	restrictbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictbutton.DoClick = function()
		local joblist = vgui.Create( "DComboBox", menu )
		joblist:SetPos( 30, 175 )
		joblist:SetSize( 190, 20 )
		joblist:CenterHorizontal()
		joblist:SetValue( "Select Restriction" )
		for k,v in pairs( DoorRestrictions ) do
			joblist:AddChoice( v.Name, k )
		end
		function joblist:OnSelect( index, value, data )
			DoorTable[entindex] = data
			net.Start( "SyncDoorTable" )
			net.WriteInt( entindex, 32 )
			net.WriteInt( data, 32 )
			net.SendToServer()
			menu:Close()
			OpenDoorMenuAdmin( ply, door )
		end
	end
	
	local restrictremove = vgui.Create( "DButton", menu )
	restrictremove:SetText( "Remove Restriction" )
	restrictremove:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictremove:SetPos( 30, 210 )
	restrictremove:SetSize( 190, 30 )
	restrictremove:CenterHorizontal()
	restrictremove.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictremove.DoClick = function()
		if !DoorTable[entindex] then
			DS_Notify( ply, "This door doesn't have any restrictions to remove." )
			return
		end
		DoorTable[entindex] = nil
		net.Start( "SyncDoorTableRemove" )
		net.WriteInt( entindex, 32 )
		net.SendToServer()
		menu:Close()
		OpenDoorMenuAdmin( ply, door )
		DS_Notify( ply, "Door restriction successfully removed." )
	end

	if DoorTable.Lock[entindex] then
		local forcelock = vgui.Create( "DButton", menu )
		forcelock:SetText( "Disable Force Lock" )
		forcelock:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		forcelock:SetPos( 30, 250 )
		forcelock:SetSize( 190, 30 )
		forcelock:CenterHorizontal()
		forcelock.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		forcelock.DoClick = function()
			DoorTable.Lock[entindex] = nil
			net.Start( "SyncLockTableRemove" )
			net.WriteInt( entindex, 32 )
			net.SendToServer()
			menu:Close()
			OpenDoorMenuAdmin( ply, door )
			DS_Notify( ply, "Door will no longer lock when the server loads." )
		end
	else
		local forcelock = vgui.Create( "DButton", menu )
		forcelock:SetText( "Force Lock Door" )
		forcelock:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		forcelock:SetPos( 30, 250 )
		forcelock:SetSize( 190, 30 )
		forcelock:CenterHorizontal()
		forcelock.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		forcelock.DoClick = function()
			DoorTable.Lock[entindex] = true
			net.Start( "SyncLockTable" )
			net.WriteInt( entindex, 32 )
			net.SendToServer()
			menu:Close()
			OpenDoorMenuAdmin( ply, door )
			DS_Notify( ply, "Door will now lock when the server loads." )
		end
	end
	ply.MenuOpen = true
end

local function OpenDoorMenu( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 220, 110 )
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
		buybutton:SetSize( 190, 30 )
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
		sellbutton:SetSize( 190, 30 )
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

	local namebutton = vgui.Create( "DButton", menu )
	namebutton:SetText( "Set Door Name" )
	namebutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	namebutton:SetPos( 30, 70 )
	namebutton:SetSize( 190, 30 )
	namebutton:CenterHorizontal()
	namebutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	namebutton.DoClick = function()
		SetDoorName( ply, door )
	end
	ply.MenuOpen = true
end

local function GetDoorRestrictions( index )
	return DoorRestrictions[DoorTable[index]].Name
end

local color_red = DOOR_CONFIG_TEXT_COLOR
hook.Add( "HUDPaint", "DoorHUD", function()
	local ply = LocalPlayer()
	local ent = ply:GetEyeTrace().Entity
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local doorname = ent:GetNWString( "DoorName" )
	local entindex = ent:EntIndex()
	local keyname = language.GetPhrase( input.GetKeyName( GetConVar( "DoorKey" ):GetInt() ) )
	if ply.MenuOpen then return end
	if IsValid( ent ) and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if doorname != "" then
			draw.SimpleText( doorname, "DoorFont", ScrW() / 2, ScrH() / 2 - 20, DOOR_CONFIG_NAME_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		if IsValid( doorowner ) then
			draw.SimpleText( "Owner: "..doorowner:Nick(), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			if DoorTable[entindex] then
				draw.SimpleText( "Owner: "..GetDoorRestrictions( entindex ), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( "Owner: None", "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		draw.SimpleText( "Press "..keyname.." for door options.", "DoorFont", ScrW() / 2, ScrH() / 2 + 20, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
			draw.SimpleText( "Door Group: "..doorgroups.Name, "DoorFont", ScrW() / 2, ScrH() / 2 + 40, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end )

hook.Add( "PlayerButtonDown", "DoorButtons", function( ply, button )
	local doorkey = GetConVar( "DoorKey" ):GetInt()
	local ent = ply:GetEyeTrace().Entity
	if !IsFirstTimePredicted() or ply.MenuOpen then return end
	if IsValid( ent ) and button == doorkey and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if ply:IsSuperAdmin() or ( ply:IsAdmin() and DOOR_CONFIG_ALLOW_ADMIN ) then
			OpenDoorMenuAdmin( ply, ent )
		else
			OpenDoorMenu( ply, ent )
		end
	end
end )

net.Receive( "SyncDoorTableClient", function( len, ply )
	local tbl = net.ReadTable()
	DoorTable = tbl
end )
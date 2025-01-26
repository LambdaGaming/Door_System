local doorfile = "doorsystem/"..game.GetMap()..".json"

util.AddNetworkString( "SyncDoorTableClient" )
local function UpdateDoorTableClient( ply )
	local readtable = util.JSONToTable( file.Read( doorfile ) )
	net.Start( "SyncDoorTableClient" )
	net.WriteTable( readtable )
	net.Send( ply )
end
hook.Add( "PlayerInitialSpawn", "UpdateDoorTableClient", UpdateDoorTableClient )

util.AddNetworkString( "DS_Notify" )
function DS_Notify( ply, text )
	net.Start( "DS_Notify" )
	net.WriteString( text )
	net.Send( ply )
end

function LoadDoorTable( sync )
	local readtable = util.JSONToTable( file.Read( doorfile ) )
	DoorTable = readtable
	if sync then
		for k,v in pairs( player.GetAll() ) do
			net.Start( "SyncDoorTableClient" )
			net.WriteTable( readtable )
			net.Send( v )
		end
	end
end

local function UpdateDoorTable()
	if !file.Exists( doorfile, "DATA" ) then
		file.CreateDir( "doorsystem" )
		file.Write( doorfile, "{}" )
	end

	LoadDoorTable()

	if !DoorTable.Lock then DoorTable.Lock = {} end
	for k,v in pairs( ents.FindByClass( "prop_door*" ) ) do
		if DoorTable.Lock[v:MapCreationID()] then
			v:Fire( "Lock" )
		end
	end
	for k,v in pairs( ents.FindByClass( "func_door*" ) ) do --Using 2 for loops here since it's still faster than using ents.GetAll
		if DoorTable.Lock[v:MapCreationID()] then
			v:Fire( "Lock" )
		end
	end
end
hook.Add( "InitPostEntity", "UpdateDoorTable", UpdateDoorTable )

local function DoorCloseTimer( ply, ent )
	local index = ent:MapCreationID()
	if IsValidDoor( ent ) and DOOR_CONFIG_CLOSE_TIME > 0 and !timer.Exists( "DoorTimer"..index ) then
		timer.Create( "DoorTimer"..index, DOOR_CONFIG_CLOSE_TIME, 1, function()
			if IsValid( ent ) then ent:Fire( "Close" ) end
		end )
	end
end
hook.Add( "PlayerUse", "DoorCloseTimer", DoorCloseTimer )

function AddDoorRestriction( index, id )
	DoorTable[index] = id
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

function AddDoorLock( index )
	DoorTable.Lock[index] = true
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

function RemoveDoorRestriction( index )
	DoorTable[index] = nil
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

function RemoveDoorLock( index )
	DoorTable.Lock[index] = nil
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

function AddCoOwner( ply, index )
	if !DoorCoOwners[index] then DoorCoOwners[index] = {} end
	table.insert( DoorCoOwners[index], ply )
end

function RemoveCoOwner( ply, index )
	if DoorCoOwners[index] then
		table.RemoveByValue( DoorCoOwners[index], ply )
	end
end

util.AddNetworkString( "OwnDoor" )
net.Receive( "OwnDoor", function( len, ply )
	local ent = net.ReadEntity()
	local remoteply = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local entindex = ent:MapCreationID()
	if PlayerDoors[ply] == nil then
		PlayerDoors[ply] = 0
	end
	if override then
		ent:SetNWEntity( "DoorOwner", remoteply )
		DS_Notify( ply, "Door ownership override successful." )
		return
	end
	if DoorTable[entindex] then
		DS_Notify(ply, "This door is managed by a group and cannot be owned." )
		return
	end
	if IsValid( doorowner ) then
		if doorowner != ply then
			DS_Notify(ply, "You do not own this door." )
		else
			DS_Notify(ply, "This door is already owned by someone else." )
		end
		return
	end
	if DOOR_CONFIG_MAX_AMOUNT > 0 and PlayerDoors[ply] >= DOOR_CONFIG_MAX_AMOUNT then
		DS_Notify( ply, "You own the max amount of doors! Sell a door or sell all doors with the /sellalldoors chat command." )
		return
	end
	
	local totalPrice = 0
	if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
		local doorgroup = DoorGroups[game.GetMap()][entindex]
		toalPrice = totalPrice + ( #doorgroup.ChildDoors * DOOR_CONFIG_PRICE )
	end
	if hook.Run( "DoorSystem_CanBuyDoor", ply, ent, totalPrice ) == false then return end

	PlayerDoors[ply] = PlayerDoors[ply] + 1
	ent:SetNWEntity( "DoorOwner", ply )
	DS_Notify( ply, "You now own this door." )
	hook.Run( "DoorSystem_OnBuyDoor", ply, ent, totalPrice )

	if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
		local doorgroup = DoorGroups[game.GetMap()][entindex]
		for k,v in pairs( doorgroup.ChildDoors ) do
			local childdoor = ents.GetMapCreatedEntity( v )
			if IsValid( childdoor ) then
				if IsValid( childdoor:GetNWEntity( "DoorOwner" ) ) then
					if DOOR_CONFIG_GROUP_OVERRIDE then
						childdoor:SetNWEntity( "DoorOwner", ply )
					end
				else
					childdoor:SetNWEntity( "DoorOwner", ply )
				end					
			end
		end
		DS_Notify( ply, "You also now own all of the doors in the "..doorgroup.Name.." door group." )
	end
end )

util.AddNetworkString( "UnownDoor" )
util.AddNetworkString( "SyncCoOwnerClient" )
net.Receive( "UnownDoor", function( len, ply )
	local ent = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local entindex = ent:MapCreationID()
	if override then
		hook.Run( "DoorSystem_OnSellDoor", ply, ent )
		if PlayerDoors[doorowner] != nil and PlayerDoors[doorowner] > 0 then
			PlayerDoors[doorowner] = PlayerDoors[doorowner] - 1
		end
		ent:SetNWEntity( "DoorOwner", NULL )
		ent:SetNWString( "DoorName", "" )
		ent:Fire( "unlock", "", 0 )
		DS_Notify( ply, "Door ownership override successful." )
		DoorCoOwners[entindex] = nil
		net.Start( "SyncCoOwnerClient" )
		net.WriteTable( DoorCoOwners )
		net.Broadcast()
		return
	end
	if IsValid( doorowner ) then
		if doorowner == ply then
			ent:SetNWEntity( "DoorOwner", NULL )
			ent:SetNWString( "DoorName", "" )
			ent:Fire( "unlock", "", 0 )
			if PlayerDoors[ply] != nil and PlayerDoors[ply] > 0 then
				PlayerDoors[ply] = PlayerDoors[ply] - 1
			end
			hook.Run( "DoorSystem_OnSellDoor", ply, ent )
			DS_Notify( ply, "You have sold this door." )
			if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
				local doorgroup = DoorGroups[game.GetMap()][entindex]
				for k,v in pairs( doorgroup.ChildDoors ) do
					local childdoor = ents.GetByIndex( v )
					if IsValid( childdoor ) then
						local owner = childdoor:GetNWEntity( "DoorOwner" )
						if IsValid( owner ) and owner == ply then
							childdoor:SetNWEntity( "DoorOwner", NULL )
							childdoor:SetNWString( "DoorName", "" )
						end
					end
				end
				DS_Notify( ply, "You have also sold all of the doors in the "..doorgroup.Name.." door group." )
			end

			DoorCoOwners[entindex] = nil
			net.Start( "SyncCoOwnerClient" )
			net.WriteTable( DoorCoOwners )
			net.Broadcast()
		else
			DS_Notify(ply, "You do not own this door." )
		end
	end
end )

util.AddNetworkString( "SyncDoorTable" )
net.Receive( "SyncDoorTable", function()
	local index = net.ReadInt( 32 )
	local data = net.ReadInt( 32 )
	local remove = net.ReadBool()
	if remove then
		RemoveDoorRestriction( index )
		return
	end
	AddDoorRestriction( index, data )
end )

util.AddNetworkString( "SyncLockTable" )
net.Receive( "SyncLockTable", function()
	local index = net.ReadInt( 32 )
	local remove = net.ReadBool()
	local ent = ents.GetByIndex( index )
	if remove then
		RemoveDoorLock( index )
		ent:Fire( "Unlock" )
		return
	end
	AddDoorLock( index )
	ent:Fire( "Lock" )
end )

util.AddNetworkString( "SetDoorName" )
net.Receive( "SetDoorName", function()
	local ent = net.ReadEntity()
	local name = net.ReadString()
	ent:SetNWString( "DoorName", name )
end )

util.AddNetworkString( "SyncCoOwner" )
net.Receive( "SyncCoOwner", function( len, sender )
	local ply = net.ReadEntity()
	local index = net.ReadInt( 32 )
	local tbl = net.ReadTable()
	local remove = net.ReadBool()
	local door = ents.GetByIndex( index )
	if DoorTable[index] then
		DS_Notify( sender, "This door is managed by a group and cannot be owned." )
		return
	end
	if remove then
		RemoveCoOwner( ply, index )
		return
	end
	AddCoOwner( ply, index )
	net.Start( "SyncCoOwnerClient" )
	net.WriteTable( tbl )
	net.Broadcast()
end )

local function SellAllDoors( ply )
	for k,v in pairs( ents.FindByClass( "prop_door*" ) ) do
		if v:GetNWEntity( "DoorOwner" ) == ply then
			v:SetNWEntity( "DoorOwner", NULL )
			v:SetNWString( "DoorName", "" )
			v:Fire( "Unlock" )
		end
	end
	for k,v in pairs( ents.FindByClass( "func_door*" ) ) do
		if v:GetNWEntity( "DoorOwner" ) == ply then
			v:SetNWEntity( "DoorOwner", NULL )
			v:SetNWString( "DoorName", "" )
			v:Fire( "Unlock" )
		end
	end
	PlayerDoors[ply] = nil
end
hook.Add( "PlayerDisconnected", "DS_DoorDisconnect", SellAllDoors )

local function SellAllDoorsCommand( ply, text )
	if text == "/sellalldoors" then
		SellAllDoors( ply )
		DS_Notify(ply, "You have sold all of your doors." )
		return ""
	end
end
hook.Add( "PlayerSay", "DS_SellAllDoors", SellAllDoorsCommand )

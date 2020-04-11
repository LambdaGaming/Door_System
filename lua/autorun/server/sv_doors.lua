
local doorfile = "doorsystem/"..game.GetMap()..".json"

util.AddNetworkString( "SyncDoorTableClient" )
hook.Add( "PlayerInitialSpawn", "UpdateDoorTableClient", function( ply )
	local readtable = util.JSONToTable( file.Read( doorfile ) )
	net.Start( "SyncDoorTableClient" )
	net.WriteTable( readtable )
	net.Send( ply )
end )

util.AddNetworkString( "DS_Notify" )
function DS_Notify( ply, text )
	if DarkRP then
		DarkRP.notify( ply, 0, 6, text )
		return
	end
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

hook.Add( "InitPostEntity", "UpdateDoorTable", function()
	if !file.Exists( doorfile, "DATA" ) then
		file.CreateDir( "doorsystem" )
		file.Write( doorfile, "{}" )
	end

	LoadDoorTable()

	if !DoorTable.Lock then DoorTable.Lock = {} end
	for k,v in pairs( ents.FindByClass( "prop_door*" ) ) do
		if DoorTable.Lock[v:EntIndex()] then
			v:Fire( "Lock" )
		end
	end
	for k,v in pairs( ents.FindByClass( "func_door*" ) ) do --Using 2 for loops here since it's still faster than using ents.GetAll
		if DoorTable.Lock[v:EntIndex()] then
			v:Fire( "Lock" )
		end
	end
end )

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
	local entindex = ent:EntIndex()
	if override then
		ent:SetNWEntity( "DoorOwner", remoteply )
		DS_Notify(ply, DOOR_CONFIG_MESSAGES["Override Successful"])
		return
	end
	if DoorTable[entindex] then
		DS_Notify(ply, DOOR_CONFIG_MESSAGES["Managed By Another Group"])
		return
	end
	if IsValid( doorowner ) then
		if doorowner != ply then
			DS_Notify(ply, DOOR_CONFIG_MESSAGES["Do Not Own"])
		else
			DS_Notify(ply, DOOR_CONFIG_MESSAGES["Already Owned"])
		end
	else
		if PlayerDoors[ply] == nil then
			PlayerDoors[ply] = 0
		end
		if DarkRP then
			if DOOR_CONFIG_DOOR_GROUPS_ENABLED and DOOR_CONFIG_CHARGE_EXTRA and DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
				local doorgroup = DoorGroups[game.GetMap()][entindex]
				local groupedprice = #doorgroup.ChildDoors * DOOR_CONFIG_PRICE
				if DOOR_CONFIG_PRICE_CHECK(ply, groupedprice) then
					hook.Run("Door_System_Purchase", ply, ent, groupedprice)
					DoorFunctions.DOOR_PURCHASE(ply, groupedprice)
				else
					DS_Notify(ply, DOOR_CONFIG_MESSAGES["Cannot Afford"])
					return
				end
				if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
					local doorgroup = DoorGroups[game.GetMap()][entindex]
					for k,v in pairs( doorgroup.ChildDoors ) do
						local childdoor = ents.GetByIndex( v )
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
			end
		end
		if DoorFunctions.DOOR_PRICE_CHECK(ply) then
			if DOOR_CONFIG_ALLOWED_DOOR_AMOUNT > 0 then
				if PlayerDoors[ply] < DOOR_CONFIG_ALLOWED_DOOR_AMOUNT then
					hook.Run("Door_System_Purchase", ply, ent, DOOR_CONFIG_ALLOWED_DOOR_AMOUNT)
					DoorFunctions.DOOR_PURCHASE(ply)
					PlayerDoors[ply] = PlayerDoors[ply] + 1
					ent:SetNWEntity( "DoorOwner", ply )
					DS_Notify( ply, DoorFunctions.OWN_MESSAGE(ply))
				else DS_Notify( ply, DOOR_CONFIG_MESSAGES["Ran Out of Doors"]) end
			else
				DoorFunctions.DOOR_PURCHASE(ply)
				DS_Notify(ply, DoorFunctions.OWN_MESSAGE(ply))
				ent:SetNWEntity( "DoorOwner", ply )
			end
		else
			DS_Notify(ply, DOOR_CONFIG_MESSAGES["Cannot Afford"])
			return
		end
	end
end )

util.AddNetworkString( "UnownDoor" )
util.AddNetworkString( "SyncCoOwnerClient" )
net.Receive( "UnownDoor", function( len, ply )
	local ent = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local entindex = ent:EntIndex()
	if override then
		hook.Run("Door_System_Sell", ply, doorowner)
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
			hook.Run("Door_System_Sell", ply, doorowner)
			DS_Notify( ply, DOOR_CONFIG_MESSAGES["Door Sold"] )
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
				DS_Notify( ply, DOOR_CONFIG_MESSAGES["Sold From Group"] ..doorgroup.Name.." door group." )
			end

			DoorCoOwners[entindex] = nil
			net.Start( "SyncCoOwnerClient" )
			net.WriteTable( DoorCoOwners )
			net.Broadcast()
		else
			DS_Notify(ply, DOOR_CONFIG_MESSAGES["Do Not Own"])
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

util.AddNetworkString( "DarkRPDoorChat" )
net.Receive( "DarkRPDoorChat", function()
	local ply = net.ReadEntity()
	local text = net.ReadString()
	DarkRP.notify( ply, 0, 6, text )
end )

util.AddNetworkString( "SyncCoOwner" )
net.Receive( "SyncCoOwner", function( len, sender )
	local ply = net.ReadEntity()
	local index = net.ReadInt( 32 )
	local tbl = net.ReadTable()
	local remove = net.ReadBool()
	local door = ents.GetByIndex( index )
	if DoorTable[index] then
		DS_Notify( sender, "This door is locked ..." )
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

local function SellAllDoorsCommand( ply, text )
	local split = string.Split( text, " " )
	if split[1] == DOOR_CONFIG_COMMANDS["Sell All"] then --Add a check here to see if they have any doors
		SellAllDoors( ply )
		DS_Notify(ply, DOOR_CONFIG_MESSAGES["Sold All"])
		return ""
	end
end
hook.Add( "PlayerSay", "DS_SellAllDoors", SellAllDoorsCommand )
hook.Add( "PlayerDisconnected", "DS_DoorDisconnect", SellAllDoors )

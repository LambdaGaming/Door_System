
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
	timer.Simple( 5, function()
		if !file.Exists( doorfile, "DATA" ) then
			file.CreateDir( "doorsystem" )
			file.Write( doorfile, "{}" )
		end

		LoadDoorTable()

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
		DS_Notify( ply, "Door ownership override successful." )
		return
	end
	if DoorTable[entindex] then
		DS_Notify( ply, "This door is managed by a group and cannot be owned." )
		return
	end
	if IsValid( doorowner ) then
		if doorowner != ply then
			DS_Notify( ply, "This door is already owned by someone else." )
		else
			DS_Notify( ply, "You already own this door." )
		end
	else
		if DarkRP then
			if DOOR_CONFIG_CHARGE_EXTRA and DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
				local doorgroup = DoorGroups[game.GetMap()][entindex]
				local groupedprice = #doorgroup.ChildDoors * DOOR_CONFIG_PRICE
				if ply:canAfford( groupedprice ) then
					ply:addMoney( -groupedprice )
				else
					DS_Notify( "You can't afford to buy these doors." )
					return
				end
			end
			if ply:canAfford( DOOR_CONFIG_PRICE ) then
				ply:addMoney( -DOOR_CONFIG_PRICE )
			else
				DS_Notify( "You can't afford to buy this door." )
				return
			end
		end
		ent:SetNWEntity( "DoorOwner", ply )
		DS_Notify( ply, "You now own this door." )
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
end )

util.AddNetworkString( "UnownDoor" )
util.AddNetworkString( "SyncCoOwnerClient" )
net.Receive( "UnownDoor", function( len, ply )
	local ent = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local entindex = ent:EntIndex()
	if override then
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
			DS_Notify( ply, "You do not own this door." )
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

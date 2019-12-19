

local doorfile = "doorsystem/"..game.GetMap()..".json"

util.AddNetworkString( "SyncDoorTableClient" )
hook.Add( "PlayerInitialSpawn", "UpdateDoorTableClient", function( ply )
	local readtable = util.JSONToTable( file.Read( doorfile ) )
	net.Start( "SyncDoorTableClient" )
	net.WriteTable( readtable )
	net.Send( ply )
end )

function LoadDoorTable() --Not used normally, used as a dev function if the table is reset after reloading the sh_doors.lua file
	local readtable = util.JSONToTable( file.Read( doorfile ) )
	DoorTable = readtable
	for k,v in pairs( player.GetAll() ) do
		net.Start( "SyncDoorTableClient" )
		net.WriteTable( readtable )
		net.Send( v )
	end
end

hook.Add( "InitPostEntity", "UpdateDoorTable", function()
	if !file.Exists( doorfile, "DATA" ) then
		file.Write( doorfile, "{}" )
	end
	LoadDoorTable()
end )

function AddDoorRestriction( index, id )
	DoorTable[index] = id
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

function RemoveDoorRestriction( index )
	DoorTable[index] = nil
	file.Write( doorfile, util.TableToJSON( DoorTable, true ) )
end

util.AddNetworkString( "OwnDoor" )
net.Receive( "OwnDoor", function( len, ply )
	local ent = net.ReadEntity()
	local remoteply = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	if override then
		ent:SetNWEntity( "DoorOwner", remoteply )
		ply:ChatPrint( "Door ownership override successful." )
		return
	end
	if IsValid( doorowner ) then
		if doorowner != ply then
			ply:ChatPrint( "This door is already owned by someone else." )
		else
			ply:ChatPrint( "You already own this door." )
		end
	else
		ent:SetNWEntity( "DoorOwner", ply )
		ply:ChatPrint( "You now own this door." )
	end
end )

util.AddNetworkString( "UnownDoor" )
net.Receive( "UnownDoor", function( len, ply )
	local ent = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	if override then
		ent:SetNWEntity( "DoorOwner", NULL )
		ent:Fire( "unlock", "", 0 )
		ply:ChatPrint( "Door ownership override successful." )
		return
	end
	if IsValid( doorowner ) then
		if doorowner == ply then
			ent:SetNWEntity( "DoorOwner", NULL )
			ent:Fire( "unlock", "", 0 )
			ply:ChatPrint( "You have sold this door." )
		else
			ply:ChatPrint( "You do not own this door." )
		end
	end
end )

util.AddNetworkString( "SyncDoorTable" )
net.Receive( "SyncDoorTable", function( len, ply )
	local entindex = tonumber( net.ReadString() )
	local data = tonumber( net.ReadString() )
	AddDoorRestriction( entindex, data )
end )

util.AddNetworkString( "SyncDoorTableRemove" )
net.Receive( "SyncDoorTableRemove", function( len, ply )
	local entindex = tonumber( net.ReadString() )
	RemoveDoorRestriction( entindex )
end )
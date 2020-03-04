

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
	net.Start( "DS_Notify" )
	net.WriteString( text )
	net.Send( ply )
end

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
		file.CreateDir( "doorsystem" )
		file.Write( doorfile, "{}" )
	end
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
	local entindex = ent:EntIndex()
	if override then
		ent:SetNWEntity( "DoorOwner", remoteply )
		DS_Notify( ply, "Door ownership override successful." )
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
				if ply:getDarkRPVar( "money" ) >= groupedprice then
					ply:addMoney( -groupedprice )
				else
					DS_Notify( "You can't afford to buy these doors." )
					return
				end
			end
			if ply:getDarkRPVar( "money" ) >= DOOR_CONFIG_PRICE then
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
net.Receive( "UnownDoor", function( len, ply )
	local ent = net.ReadEntity()
	local override = net.ReadBool()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local entindex = ent:EntIndex()
	if override then
		ent:SetNWEntity( "DoorOwner", NULL )
		ent:Fire( "unlock", "", 0 )
		DS_Notify( ply, "Door ownership override successful." )
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
		else
			DS_Notify( ply, "You do not own this door." )
		end
	end
end )

util.AddNetworkString( "SyncDoorTable" )
net.Receive( "SyncDoorTable", function()
	local entindex = tonumber( net.ReadString() )
	local data = tonumber( net.ReadString() )
	AddDoorRestriction( entindex, data )
end )

util.AddNetworkString( "SyncDoorTableRemove" )
net.Receive( "SyncDoorTableRemove", function()
	local entindex = tonumber( net.ReadString() )
	RemoveDoorRestriction( entindex )
end )

util.AddNetworkString( "SetDoorName" )
net.Receive( "SetDoorName", function()
	local ent = net.ReadEntity()
	local name = net.ReadString()
	ent:SetNWString( "DoorName", name )
end )
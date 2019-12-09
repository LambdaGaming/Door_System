
util.AddNetworkString( "OwnDoor" )
net.Receive( "OwnDoor", function( len, ply )
	local ent = net.ReadEntity()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	if IsValid( doorowner ) then
		if doorowner != ply then
			if DarkRP then
				DarkRP.notify( ply, 1, 6, "This door is already owned by someone else." )
				return
			end
			ply:ChatPrint( "This door is already owned by someone else." )
		else
			if DarkRP then
				DarkRP.notify( ply, 1, 6, "You already own this door." )
				return
			end
			ply:ChatPrint( "You already own this door." )
		end
	else
		ent:SetNWEntity( "DoorOwner", ply )
		if DarkRP then
			if DOOR_CONFIG_PRICE > 0 then
				ply:addMoney( -DOOR_CONFIG_PRICE )
			end
			DarkRP.notify( ply, 0, 6, "You have purchased this door for "..DarkRP.formatMoney( DOOR_CONFIG_PRICE ).."." )
			return
		end
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
			if DarkRP then
				if DOOR_CONFIG_SELL_PRICE > 0 then
					ply:addMoney( DOOR_CONFIG_SELL_PRICE )
				end
				DarkRP.notify( ply, 0, 6, "You have sold this door for "..DarkRP.formatMoney( DOOR_CONFIG_SELL_PRICE ).."." )
				return
			end
			ply:ChatPrint( "You have sold this door." )
		else
			if DarkRP then
				DarkRP.notify( "You do not own this door." )
				return
			end
			ply:ChatPrint( "You do not own this door." )
		end
	end
end )
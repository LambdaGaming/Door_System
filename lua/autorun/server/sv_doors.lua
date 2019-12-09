
util.AddNetworkString( "BuyDoor" )
net.Receive( "BuyDoor", function( len, ply )
	local ent = net.ReadEntity()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
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

util.AddNetworkString( "SellDoor" )
net.Receive( "SellDoor", function( len, ply )
	local ent = net.ReadEntity()
	local doorowner = ent:GetNWEntity( "DoorOwner" )
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
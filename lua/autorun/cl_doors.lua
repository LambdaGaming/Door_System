
surface.CreateFont( "DoorFont", {
	font = "Arial",
	size = 15
} )

hook.Add( "HUDPaint", "DoorHUD", function()
	local ply = LocalPlayer()
	local ent = ply:GetEyeTrace().Entity
	local allowed = {
		["prop_door"] = true,
		["prop_door_rotating"] = true,
		["func_door"] = true,
		["func_door_rotating"] = true
	}
	if IsValid( ent ) and ply:GetPos():DistToSqr( ent:GetPos() ) < 10000 and allowed[ent:GetClass()] then
		if ent.DoorOwner then
			draw.SimpleText( "Owner: "..ent.DoorOwner:Nick(), "DermaDefault", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Owner: None", "DermaDefault", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end )
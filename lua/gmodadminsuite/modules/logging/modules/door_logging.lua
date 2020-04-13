local function GetEntityPosRounded(ent)
	local v = ent:GetPos()
	return {
		x = math.Round(v.x),
		y = math.Round(v.y),
		z = math.Round(v.z)
	}
end

local function GetEntityPosRoundedString(ent)
	v = GetEntityPosRounded(ent)
	x = v.x
	y = v.y
	z = v.z
	return "X: " .. x .. ", Y: " .. y .. ", Z: " .. z
end

local DOOR_PURCHASE = GAS.Logging:MODULE()

DOOR_PURCHASE.Category = "Door System"
DOOR_PURCHASE.Name     = "Door Purchased"
DOOR_PURCHASE.Colour   = Color(254, 89, 0)

DOOR_PURCHASE:Setup(function()
	DOOR_PURCHASE:Hook("Door_System_Purchase", "OnDoorPurchase", function(ply, ent, price)
		DOOR_PURCHASE:Log("{1} purchased door: {2} at {3} for {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatProp(ent), GAS.Logging:Highlight(GetEntityPosRoundedString(ent)), GAS.Logging:FormatMoney(price)) 
	end)
end)

GAS.Logging:AddModule(DOOR_PURCHASE)

local DOOR_SELL = GAS.Logging:MODULE()

DOOR_SELL.Category = "Door System"
DOOR_SELL.Name     = "Door Sold"
DOOR_SELL.Colour   = Color(254, 89, 0)

DOOR_SELL:Setup(function()
	DOOR_SELL:Hook("Door_System_Sell", "OnDoorSell", function(ply, ent)
		DOOR_SELL:Log("{1} sold door: {2} at {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatProp(ent), GAS.Logging:Highlight(GetEntityPosRoundedString(ent)))
	end)
end)

GAS.Logging:AddModule(DOOR_SELL)
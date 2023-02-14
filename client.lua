local customturbo = {}
local turboboost = {}
AddStateBagChangeHandler('turbo' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(500)
	if not value then return end
    local net = tonumber(bagName:gsub('entity:', ''), 10)
    local vehicle = NetworkGetEntityFromNetworkId(net)
	local ent = Entity(vehicle).state
	local plate = GetVehicleNumberPlateText(vehicle)
	customturbo[plate] = value
	print('turbo', value.turbo, customturbo[plate])
	local weightadded = Config.turbos[value.turbo].weight
	local weight = GetVehicleHandlingInt(vehicle,'CHandlingData', 'fMass')
	if turboboost[plate] ~= value.turbo then
		turboboost[plate] = value.turbo
		SetVehicleHandlingInt(vehicle , "CHandlingData", "fMass", tonumber(weight)*weightadded)
	end
	if GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
		StartTurboLoop(plate,vehicle)
	end
end)

invehicle = false
AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		if args[1] == PlayerId() then
			local plate = GetVehicleNumberPlateText(args[2])
			print(customturbo[plate])
			if customturbo[plate] and DoesEntityExist(args[2]) then
				Wait(3000)
				StartTurboLoop(plate,args[2])
			end
		end
	end
end)

local exportboost = 1.0
exports('BoostPerGear', function(percent)
	exportboost = percent
end)

local boosted = false
StartTurboLoop = function(plate,vehicle)
	if boosted then return end
	if invehicle then return end
	local vehicle = vehicle
	if customturbo[plate] then
		boosted = true
		print("Turbo Loop")
		invehicle = true
		local turbo = Config.turbos[customturbo[plate].turbo]
		local default = {fDriveInertia = GetVehicleHandlingFloat(vehicle , "CHandlingData","fDriveInertia"), fInitialDriveForce = GetVehicleHandlingFloat(vehicle , "CHandlingData","fInitialDriveForce")}
		ToggleVehicleMod(vehicle,18,true)
		local sound = false
		local soundofnitro = nil
		local customized = false
		local boost = 0
		local oldgear = 1
		local cd = 0
		local rpm = GetVehicleCurrentRpm(vehicle)
		local gear = GetVehicleCurrentGear(vehicle)
		local maxvol = 0.4
		local ent = Entity(vehicle).state
		local maxtorque = turbo.Torque
		while customturbo[plate] ~= nil and customturbo[plate].turbo ~= 'Default' and IsPedInAnyVehicle(PlayerPedId()) do
			local durability = (ent.turbo?.durability or 100.0) / 100
			turbo = Config.turbos[customturbo[plate].turbo]
			while IsControlPressed(0, 32) do
				rpm = GetVehicleCurrentRpm(vehicle)
				if boost <= maxtorque and turbo.rpmboost <= rpm then
					local powercurve = (turbo.Power * (1 + (rpm*2)))
					boost = maxtorque < boost and (boost + powercurve) or maxtorque
				end
				cd = cd + 10
				gear = GetVehicleCurrentGear(vehicle)
				SetVehicleTurboPressure(vehicle , boost)
				if GetVehicleTurboPressure(vehicle)+0.1 >= maxtorque then
					local power = (GetVehicleTurboPressure(vehicle) * (rpm < 0.8 and 0.5+rpm or rpm+0.2) * exportboost) * durability
					if ent.nitroenable then
						power = power + ent.nitropower
					end
					SetVehicleCheatPowerIncrease(vehicle,power)
				end
				if not sound then
					StopSound(soundofnitro)
					ReleaseSoundId(soundofnitro)
					soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle , "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
					sound = true
				end
				if sound and not IsControlPressed(1, 32) or IsControlPressed(1, 32) and rpm > 0.8 and oldgear ~= gear then
					StopSound(soundofnitro)
					ReleaseSoundId(soundofnitro)
					if customturbo[plate].turbo == 'Ultimate' then
						SetVehicleBoostActive(vehicle,1,0)
					end
					sound = false
					local table = {
						['file'] = customturbo[plate].turbo,
						['volume'] = maxvol * (boost / maxtorque),
						['coord'] = GetEntityCoords(PlayerPedId())
					}
					if GetVehicleTurboPressure(vehicle)+0.1 >= maxtorque and cd >= 1000 then
						TriggerServerEvent('renzu_turbo:soundsync',table,NetworkGetNetworkIdFromEntity(vehicle),exportboost)
						cd = 0
					end
					boost = 0
					oldgear = gear
				end
				Wait(0)
			end
			if sound and not IsControlPressed(1, 32) or IsControlPressed(1, 32) and rpm > 0.8 and oldgear ~= gear then
				StopSound(soundofnitro)
				ReleaseSoundId(soundofnitro)
				sound = false
				local table = {
					['file'] = customturbo[plate].turbo,
					['volume'] = maxvol * (boost / maxtorque),
					['coord'] = GetEntityCoords(PlayerPedId())
				}
				if GetVehicleTurboPressure(vehicle)+0.1 >= maxtorque and cd >= 1000 then
					TriggerServerEvent('renzu_turbo:soundsync',table,NetworkGetNetworkIdFromEntity(vehicle),exportboost)
					cd = 0
				end
				boost = 0
				oldgear = gear
			end
			boost = 0
			vehicle = GetVehiclePedIsIn(PlayerPedId())
			if customturbo[plate].turbo == 'Default' then
				break
			end
			turbo = Config.turbos[customturbo[plate].turbo]
			if vehicle == 0 then
				break
			end
			Wait(500)
			Wait(7)
			customized = true
		end
		invehicle = false
		boosted = false
		if customized then
			Wait(1000)
		end
	end
end

RegisterNetEvent('renzu_turbo:soundsync')
AddEventHandler('renzu_turbo:soundsync', function(table)
    local volume = table['volume']
	local mycoord = GetEntityCoords(PlayerPedId())
	local distIs  = tonumber(string.format("%.1f", #(mycoord - table['coord'])))
	if (distIs <= 30) then
		distPerc = distIs / 30
		volume = (1-distPerc) * table['volume']
		local table = {
			['file'] = table['file'],
			['volume'] = volume
		}
		SendNUIMessage({
			type = "playsound",
			content = table
		})
	end
end)
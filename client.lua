local vehicle_sounds = {}

vehiclehandling = {}
enginespec = false
local customturbo = {}

AddStateBagChangeHandler('turbo' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	-- Wait(0)
	-- if not value then return end
    local net = tonumber(bagName:gsub('entity:', ''), 10)
    local vehicle = NetworkGetEntityFromNetworkId(net)
	local ent = Entity(vehicle).state
	local plate = GetVehicleNumberPlateText(vehicle)
	customturbo[plate] = value
	print('turbo', value)
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
				Wait(2000)
				StartTurboLoop(plate,args[2])
			end
		end
	end
end)

StartTurboLoop = function(plate,vehicle)
	if invehicle then return end
	local vehicle = vehicle
	if customturbo[plate] then
		print("Turbo Loop")
		invehicle = true
		local turbo = Config.turbos[customturbo[plate]]
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
		while customturbo[plate] ~= nil and customturbo[plate] ~= 'Default' and IsPedInAnyVehicle(PlayerPedId()) do
			turbo = Config.turbos[customturbo[plate]]
			while IsControlPressed(0, 32) do
				if turbo.Torque > boost then
					boost = boost + 0.01
				end
				cd = cd + 10
				rpm = GetVehicleCurrentRpm(vehicle)
				gear = GetVehicleCurrentGear(vehicle)
				SetVehicleTurboPressure(vehicle , boost + turbo.Power * rpm)
				if GetVehicleTurboPressure(vehicle) >= turbo.Power then
					local power = turbo.Power
					if ent.nitroenable then
						power = power + ent.nitropower
					end
					SetVehicleCheatPowerIncrease(vehicle,power * GetVehicleTurboPressure(vehicle))
				end
				if not sound then
					soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle , "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
					sound = true
				end
				if sound and not IsControlPressed(1, 32) or IsControlPressed(1, 32) and rpm > 0.8 and oldgear ~= gear then
					StopSound(soundofnitro)
					ReleaseSoundId(soundofnitro)
					sound = false
					local table = {
						['file'] = customturbo[plate],
						['volume'] = maxvol * (boost / turbo.Power),
						['coord'] = GetEntityCoords(PlayerPedId())
					}
					if GetVehicleTurboPressure(vehicle) >= turbo.Power and cd >= 1000 then
						TriggerServerEvent('renzu_turbo:soundsync',table)
						cd = 0
					end
					boost = 0
					oldgear = gear
				end
				Wait(1)
			end
			if sound and not IsControlPressed(1, 32) or IsControlPressed(1, 32) and rpm > 0.8 and oldgear ~= gear then
				StopSound(soundofnitro)
				ReleaseSoundId(soundofnitro)
				sound = false
				local table = {
					['file'] = customturbo[plate],
					['volume'] = maxvol * (boost / turbo.Power),
					['coord'] = GetEntityCoords(PlayerPedId())
				}
				if GetVehicleTurboPressure(vehicle) >= turbo.Power and cd >= 1000 then
					TriggerServerEvent('renzu_turbo:soundsync',table)
					cd = 0
				end
				boost = 0
				oldgear = gear
			end
			boost = 0
			vehicle = GetVehiclePedIsIn(PlayerPedId())
			if customturbo[plate] == 'Default' then
				break
			end
			turbo = Config.turbos[customturbo[plate]]
			if vehicle == 0 then
				break
			end
			Wait(500)
			Wait(7)
			customized = true
		end
		invehicle = false
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


ESX = nil
QBCore = nil
RegisterServerCallBack_ = nil
RegisterUsableItem = nil
Initialized()
turbos = {}

RegisterCommand("changeturbo", function(source, args, rawCommand)
       local source = source
       local xPlayer = GetPlayerFromId(source)
       local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
       print(veh,GetPlayerPed(source))
       if xPlayer.getGroup() ~= 'user' and Config.turbos[args[1]] and args[1] ~= nil and veh ~= 0 then
                     plate = GetVehicleNumberPlateText(veh)
                     if turbos[plate] == nil then
                            turbos[plate] = {}
                     end
                     turbos[plate].turbo = args[1]
                     turbos[plate].plate = plate
                     turbos[plate].durability = 100.0
                     local ent = Entity(veh).state
                     ent:set('turbo',turbos[plate], true)
                     SaveTurbo(plate,args[1])
       end
end, false)

GetTurboType = function(type)
       for k,v in pairs(Config.turbos) do
              if v.item == type then
                     return k
              end
       end
       return false
end

AddTurbo = function(net,type)
       local vehicle = NetworkGetEntityFromNetworkId(net)
       local turbo = GetTurboType(type)
       if not DoesEntityExist(vehicle) or not turbo then return end
       local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1'):upper()
       if turbos[plate] == nil then
              turbos[plate] = {}
       end
       turbos[plate].turbo = turbo
       turbos[plate].plate = plate
       turbos[plate].durability = 100.0
       local ent = Entity(vehicle).state
       ent:set('turbo',turbos[plate], true)
       SaveTurbo(plate,turbo)
end

exports('AddTurbo', AddTurbo)
RegisterNetEvent('renzu_turbo:AddTurbo', AddTurbo)

Citizen.CreateThread(function()
       Wait(1000)
       local ret = json.decode(GetResourceKvpString('renzu_turbo') or '[]') or {}
       for k,v in pairs(ret) do
              if not turbos[k] then turbos[k] = {} end
              turbos[k].plate = k
              turbos[k].turbo = v.turbo
              turbos[k].durability = v.durability or 100.0
       end

       for k,v in ipairs(GetAllVehicles()) do
              local plate = GetVehicleNumberPlateText(v)
              if turbos[plate] and plate == turbos[plate].plate then
                     local ent = Entity(v).state
                     if turbos[plate].durability == nil then
                            turbos[plate].durability = 100.0
                     end
                     ent:set('turbo',turbos[plate], true)
              end
       end

       while true do
              Wait(60000)
              local turbodata = {}
              for k,v in pairs(turbos) do
                     turbodata[v.plate] = v
              end
              SetResourceKvp('renzu_turbo',json.encode(turbodata))
       end
end)

function SaveTurbo(plate,turbo)
              local data = json.decode(GetResourceKvpString('renzu_turbo') or '[]') or {}
              data[plate] = turbo
              SetResourceKvp('renzu_turbo',json.encode(data))
end

function firstToUpper(str)
       return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
       for v, k in pairs(Config.turbos) do
              local turboname = string.lower(v)
              print("register item", v)
              RegisterUsableItem("turbo"..turboname.."", function(source)
                     local xPlayer = GetPlayerFromId(source)
                     if Config.jobonly and xPlayer.job.name ~= tostring(Config.turbojob) then print("not mech") return end
                     xPlayer.removeInventoryItem("turbo"..turboname.."", 1)
                     local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
                     local turbo = turboname
                     if turbo ~= nil and veh ~= 0 then
                            plate = GetVehicleNumberPlateText(veh)
                            if turbos[plate] == nil then
                                   turbos[plate] = {}
                            end
                            turbos[plate].current = turbos[plate].turbo or v
                            turbos[plate].turbo = v
                            turbos[plate].plate = plate
                            local ent = Entity(veh).state
                            ent:set('turbo',turbos[plate],true)
                            SaveTurbo(plate,v)
                     end
              end)
       end
       print(" TURBO LOADED ")
end)

AddStateBagChangeHandler('bov' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
       local net = tonumber(bagName:gsub('entity:', ''), 10)
       if not value then return end
       local entity = NetworkGetEntityFromNetworkId(net)
       if DoesEntityExist(entity) then
              local ent = Entity(entity).state
              local plate = GetVehicleNumberPlateText(entity)
              local state = ent.turbo or {}
              if not state.durability then
                     state.durability = 100.0
              end
              state.durability -= (0.05) * value.boost
              if state then
                     ent:set('turbo',state,true)
                     turbos[plate].durability = state.durability
              end
              Wait(0)
              ent:set('bov',false,true)
       end
end)

SetTurbo = function(entity)
       if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
              local plate = GetVehicleNumberPlateText(entity)
              if turbos[plate] and turbos[plate].turbo then
                     local ent = Entity(entity).state
                     ent:set('turbo',turbos[plate],true)
              end
       end
end

AddStateBagChangeHandler('VehicleProperties' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	local net = tonumber(bagName:gsub('entity:', ''), 10)
	if not value then return end
              local entity = NetworkGetEntityFromNetworkId(net)
              Wait(1000)
              if DoesEntityExist(entity) then
                     SetTurbo(entity) -- compatibility with ESX onesync server setter vehicle spawn
              end
end)

AddEventHandler('entityCreated', function(entity)
       local entity = entity
       Wait(2000)
       SetTurbo(entity)
end)


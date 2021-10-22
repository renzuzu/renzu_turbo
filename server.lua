

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
turbos = {}

RegisterCommand("changeturbo", function(source, args, rawCommand)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  print(veh,GetPlayerPed(source))
  if xPlayer.getGroup() ~= 'user' and Config.turbos[args[1]] and args[1] ~= nil and veh ~= 0 then
      plate = GetVehicleNumberPlateText(veh)
      if turbos[plate] == nil then
        turbos[plate] = {}
      end
      turbos[plate].turbo = args[1]
      turbos[plate].plate = plate
      local ent = Entity(veh).state
      ent.turbo = turbos[plate].turbo
      ent.turbopower = Config.turbos[ent.turbo].Power
      SaveTurbo(plate,args[1])
  end
end, false)

Citizen.CreateThread(function()
  local ret = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_turbo', {})
  for k,v in pairs(ret) do
    turbos[v.plate] = v
    turbos[v.plate].turbo = v.turbo
    turbos[v.plate].current = v.turbo
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if turbos[plate] and plate == turbos[plate].plate then
      local ent = Entity(v).state
      ent.turbo = turbos[plate].turbo
      ent.turbopower = Config.turbos[ent.turbo].Power
    end
  end
end)

function SaveTurbo(plate,turbo)
    local result = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_turbo WHERE TRIM(plate) = @plate', {['@plate'] = plate})
    if result[1] == nil then
        SqlFunc(Config.Mysql,'execute','INSERT INTO renzu_turbo (plate, turbo) VALUES (@plate, @turbo)', {
            ['@plate']   = plate,
            ['@turbo']   = turbo,
        })
    elseif result[1] then
        SqlFunc(Config.Mysql,'execute','UPDATE renzu_turbo SET turbo = @turbo WHERE TRIM(plate) = @plate', {
            ['@plate'] = plate,
            ['@turbo'] = turbo,
        })
    end
end

function SqlFunc(plugin,type,query,var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
		    MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:fetch(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
  c = 0
  for v, k in pairs(Config.turbos) do
    c = c + 1
    local turboname = string.lower(v)
    local label = string.upper(v)
    foundRow = SqlFunc(Config.Mysql,'fetchAll',"SELECT * FROM items WHERE name = @name", {
      ['@name'] = "turbo"..turboname..""
    })
    if foundRow[1] == nil then
      local weight = 'limit'
      if Config.weight_type then
        SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)", {
          ['@name'] = "turbo"..turboname.."",
          ['@label'] = ""..firstToUpper(turboname).." Turbo",
          ['@weight'] = Config.weight
        })
        print("Inserting "..turboname.."")
      else
        SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label) VALUES (@name, @label)", {
          ['@name'] = "turbo"..turboname.."",
          ['@label'] = ""..firstToUpper(turboname).." Turbo",
        })
        print("Inserting "..turboname.."")
      end
    end
  end
  while ESX == nil do Wait(10) end
  for v, k in pairs(Config.turbos) do
    local turboname = string.lower(v)
    print("register item", v)
    ESX.RegisterUsableItem("turbo"..turboname.."", function(source)
      local xPlayer = ESX.GetPlayerFromId(source)
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
        ent.turbo = turbos[plate].turbo
        ent.turbopower = Config.turbos[ent.turbo].Power
        SaveTurbo(plate,v)
      end
    end)
  end
  print(" TURBO LOADED ")
end)

RegisterNetEvent('renzu_turbo:soundsync')
AddEventHandler('renzu_turbo:soundsync', function(table)
    TriggerClientEvent('renzu_turbo:soundsync',-1,table)
end)

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(500)
  if GetEntityPopulationType(entity) == 7 and DoesEntityExist(entity) then
    Wait(4000)
    local plate = GetVehicleNumberPlateText(entity)
    if turbos[plate] and turbos[plate].turbo then
      local ent = Entity(entity).state
      ent.turbo = turbos[plate].turbo
      ent.turbopower = Config.turbos[ent.turbo].Power
    end
  end
end)
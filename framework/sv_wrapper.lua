Using = {}
function Initialized()
	if Config.framework == 'ESX' then
		ESX = exports['es_extended']:getSharedObject()
		RegisterServerCallBack_ = ESX.RegisterServerCallback
		RegisterUsableItem = ESX.RegisterUsableItem
		vehicletable = 'owned_vehicles'
		vehiclemod = 'vehicle'
		QBCore = {}
	elseif Config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetCoreObject()
		RegisterServerCallBack_ =  QBCore.Functions.CreateCallback
		RegisterUsableItem = QBCore.Functions.CreateUseableItem
		vehicletable = 'player_vehicles '
		vehiclemod = 'mods'
		owner = 'license'
		stored = 'state'
		garage_id = 'garage'
		type_ = 'vehicle'
		ESX = {}
	end
end

function ItemMeta(name,data,xPlayer)
	local xPlayer <const> = xPlayer
	local name <const> = name
	if Config.framework == 'ESX' then
		local Inventory = exports.ox_inventory:Inventory()
		local item = Inventory.Search(xPlayer.source, 1, name)
		local source = tonumber(source)
		if not Using[source] then
			Using[source] = {}
		end
		while not Using[source][k] do Wait(100) end
		local meta = nil
		for k2,v in pairs(item) do
			if v.slot == Using[source][k] then
				meta = v.metadata.type
			end
		end
		return meta
	else
		local data <const> = data
		print(data.slot,'SLOT ID')
		return data.info
	end
end

-- OX LOGIC
RegisterServerEvent('ox_inventory:ServerCallback') -- temporary logic unless theres a way to fetch current usable slot id from server, please educate me
AddEventHandler('ox_inventory:ServerCallback', function(name, item, slot, metadata)
    if name == 'cb:ox_inventory:useItem' then
        if not Using[tonumber(source)] then Using[tonumber(source)] = {} end
        Using[tonumber(source)][item] = slot
    end
end)
-- OX LOGIC


function GetPlayerFromIdentifier(identifier)
	self = {}
	if Config.framework == 'ESX' then
		local player = ESX.GetPlayerFromIdentifier(identifier)
		self.src = player.source
		return player
	else
		local getsrc = QBCore.Functions.GetSource(identifier)
		self.src = getsrc
		print(getsrc,identifier)
		selfcore = {}
		selfcore.data = QBCore.Functions.GetPlayer(self.src)
		print(self.src)
		if selfcore.data.identifier == nil then
			selfcore.data.identifier = selfcore.data.PlayerData.license
			print(selfcore.data.identifier,'gago')
		end
		if selfcore.data.citizenid == nil then
			selfcore.data.citizenid = selfcore.data.PlayerData.citizenid
		end
		if selfcore.data.job == nil then
			selfcore.data.job = selfcore.data.PlayerData.job
		end

		selfcore.data.getMoney = function(value)
			return selfcore.data.PlayerData.money['cash']
		end
		selfcore.data.addMoney = function(value)
				QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.AddMoney('cash',tonumber(value))
			return true
		end
		selfcore.data.removeMoney = function(value)
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveMoney('cash',tonumber(value))
			return true
		end
		selfcore.data.getAccount = function(type)
			if type == 'money' then
				type = 'cash'
			end
			return {money = selfcore.data.PlayerData.money[type]}
		end
		selfcore.data.removeAccountMoney = function(type,val)
			if type == 'money' then
				type = 'cash'
			end
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveMoney(type,tonumber(val))
			return true
		end
		selfcore.data.showNotification = function(msg)
			TriggerEvent('QBCore:Notify',self.src, msg)
			return true
		end
		if selfcore.data.source == nil then
			selfcore.data.source = self.src
		end
		selfcore.data.addInventoryItem = function(item,amount,info,slot)
			local info = info
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.AddItem(item,amount,slot or false,info)
		end
		selfcore.data.removeInventoryItem = function(item,amount,slot)
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveItem(item, amount, slot or false)
		end
		selfcore.data.getInventoryItem = function(item)
			local gi = QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.GetItemByName(item)
			gi.count = gi.amount
			return gi
		end
		-- we only do wrapper or shortcuts for what we used here.
		-- a lot of qbcore functions and variables need to port , its possible to port all, but we only port what this script needs.
		return selfcore.data
	end
end

function GetPlayerFromId(src)
	self = {}
	self.src = src
	if Config.framework == 'ESX' then
		return ESX.GetPlayerFromId(self.src)
	elseif Config.framework == 'QBCORE' then
		selfcore = {}
		selfcore.data = QBCore.Functions.GetPlayer(self.src)
		if selfcore.data.identifier == nil then
			selfcore.data.identifier = selfcore.data.PlayerData.license
		end
		if selfcore.data.citizenid == nil then
			selfcore.data.citizenid = selfcore.data.PlayerData.citizenid
		end
		if selfcore.data.job == nil then
			selfcore.data.job = selfcore.data.PlayerData.job
		end

		selfcore.data.getMoney = function(value)
			return selfcore.data.PlayerData.money['cash']
		end
		selfcore.data.addMoney = function(value)
				QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.AddMoney('cash',tonumber(value))
			return true
		end
		selfcore.data.removeMoney = function(value)
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveMoney('cash',tonumber(value))
			return true
		end
		selfcore.data.getAccount = function(type)
			if type == 'money' then
				type = 'cash'
			end
			return {money = selfcore.data.PlayerData.money[type]}
		end
		selfcore.data.removeAccountMoney = function(type,val)
			if type == 'money' then
				type = 'cash'
			end
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveMoney(type,tonumber(val))
			return true
		end
		selfcore.data.showNotification = function(msg)
			TriggerEvent('QBCore:Notify',self.src, msg)
			return true
		end
		selfcore.data.addInventoryItem = function(item,amount,info,slot)
			local info = info
			print(info,'META INFO')
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.AddItem(item,amount,slot or false,info)
		end
		selfcore.data.removeInventoryItem = function(item,amount,slot)
			QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveItem(item, amount, slot or false)
		end
		selfcore.data.getInventoryItem = function(item)
			print(item)
			local gi = QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.GetItemByName(item) or {count = 0}
			gi.count = gi.amount
			return gi
		end
		selfcore.data.getGroup = function()
			return QBCore.Functions.IsOptin(self.src)
		end
		if selfcore.data.source == nil then
			selfcore.data.source = self.src
		end
		-- we only do wrapper or shortcuts for what we used here.
		-- a lot of qbcore functions and variables need to port , its possible to port all, but we only port what this script needs.
		return selfcore.data
	end
end

function VehicleNames()
	if Config.framework == 'ESX' then
		vehiclesname = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM vehicles', {})
	elseif Config.framework == 'QBCORE' then
		vehiclesname = QBCore.Shared.Vehicles
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
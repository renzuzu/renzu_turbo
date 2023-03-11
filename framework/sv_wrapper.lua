Using = {}
Config.framework = GetResourceState('es_extended') == 'started' and 'ESX' or 'QBCORE'
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
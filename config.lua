Config = {}
Config.framework = 'ESX'
Config.Mysql = 'mysql-async'
Config.weight_type = false
Config.weight = 1.5
Config.jobonly = false
Config.turbojob = 'mechanic'
Config.turbos = {
	Street = {label = 'Turbo Street', Power = 0.2, Torque = 1.4, value = 25000, item = 'turbostreet', weight = 1.05, rpmboost = 0.3, lag = 3},
	Sports = {label = 'Turbo Sports',Power = 0.35, Torque = 1.8, value = 55000, item = 'turbosports', weight = 1.10, rpmboost = 0.45, lag = 7},
	Racing = {label = 'Turbo Racing',Power = 0.55, Torque = 2.3, value = 125000, item = 'turboracing', weight = 1.12, rpmboost = 0.55, lag = 10},
	Ultimate = {label = 'Turbo Ultimate',Power = 0.8, Torque = 3.2, value = 125000, item = 'turboultimate', weight = 1.14, rpmboost = 0.7, lag = 12},
}

exports('turbos', function()
	return Config.turbos
end)
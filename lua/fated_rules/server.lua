util.AddNetworkString('FatedRules-ToClient')
util.AddNetworkString('FatedRules-ToServer')

hook.Add('Initialize', 'FatedRules.SetupData', function()
	if !file.Exists('fated_rules_cfg.txt', 'DATA') then
		FatedRules.data = {}

		file.Write('fated_rules_cfg.txt', util.TableToJSON(FatedRules.data))
	else
		FatedRules.data = util.JSONToTable(file.Read('fated_rules_cfg.txt', 'DATA'))
	end
end)

hook.Add('PlayerInitialSpawn', 'FatedRules.SendData', function(pl)
	net.Start('FatedRules-ToClient')
		net.WriteTable(FatedRules.data)
	net.Send(pl)
end)

net.Receive('FatedRules-ToServer', function(len, pl)
	if pl:IsSuperAdmin() then
		local tabl = net.ReadTable()

		file.Write('fated_rules_cfg.txt', util.TableToJSON(tabl))

		FatedRules.data = tabl

		net.Start('FatedRules-ToClient')
			net.WriteTable(tabl)
		net.Broadcast()
	end
end)

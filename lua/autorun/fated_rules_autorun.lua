FatedRules = FatedRules or {}

local FileCl = SERVER and AddCSLuaFile or include
local FileSv = SERVER and include or function() end

FileSv('fated_rules/server.lua')
FileCl('fated_rules/client.lua')

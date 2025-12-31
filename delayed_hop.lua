-- getgenv().Serverhop = {
--     Delay = "900",
--     InitScript = "loadstring(game:HttpGet(''))()"
-- }

local hop = loadstring(game:HttpGet("https://raw.githubusercontent.com/pl4xi/serverhop/refs/heads/main/serverhop.lua"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local FolderName = "Delayed_hop"
local ConfigPath = FolderName .. "/config.json"

queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

if not isfolder(FolderName) then 
    makefolder(FolderName)
end

local DefaultConfig = {
    Delay = "900",
    InitScript = ""
}

local Config = {}
if isfile(ConfigPath) then
    local s, e = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigPath))
    end)
    
    Config = s and e or DefaultConfig
else
    Config = DefaultConfig
end

if Serverhop then
    Config.Delay = tostring(Serverhop.Delay or Config.Delay)
    Config.InitScript = tostring(Serverhop.InitScript or Config.InitScript)
    
    appendfile(ConfigPath, HttpService:JSONEncode(Config))
end

writefile(ConfigPath, HttpService:JSONEncode(Config))

local Delay = Config.Delay
local _script = Config.InitScript

task.spawn(function()
    task.wait(tonumber(Delay))
    hop(_script)
end)

local TeleportCheck = false

LocalPlayer.OnTeleport:Connect(function(State)
	if (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		
		queueteleport([[
    		task.spawn(function()
       			loadstring(game:HttpGet('https://raw.githubusercontent.com/pl4xi/serverhop/refs/heads/main/delayed_hop.lua'))()
    		end)

    		task.spawn(function()
        		]] .. _script .. [[
    		end)
		]])
	end
end)

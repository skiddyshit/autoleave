local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlaceId, JobId = game.PlaceId, game.JobId

getgenv().Teleporting = false

queueteleport =  queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

function serverhop(_script)
    local sortOrder = "Desc"
    local requestLimit = 100 -- 100 is maximum per request
    local isExcludingFullGames = true

    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. 
               "/servers/Public?sortOrder=" .. sortOrder .. 
               "&limit=" .. requestLimit .. 
               "&excludeFullGames=" .. tostring(isExcludingFullGames)
    
    local servers = {}

    local i = 0

    while i < 100 do
        i += 1
        
        local body, s, e;
        
        task.spawn(function()
            s, e = pcall(function()
                return game:HttpGet(url)
            end)
        end)
        
        if not s then 
            warn("Request failed on attempt " .. i .. ": " .. tostring(e) .. ". Trying again..")
            task.wait(i + 6)

            continue -- Skips to next 'i'
        end 

        body = HttpService:JSONDecode(e)
        
        if body and body.data then
            for i, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                    table.insert(servers, 1, v.id)
                end
            end break;
        end
    end

    if #servers > 0 then
        task.spawn(function()
            if queueteleport then 
                queueteleport(_script)
            end 

            while not Teleporting do 
                local random_server = servers[math.random(1, #servers)]
                
                if random_server then
                    TeleportService:TeleportToPlaceInstance(PlaceId, random_server, LocalPlayer)
                end

                task.wait(3)
            end
        end)

        LocalPlayer.OnTeleport:Connect(function(State)
            getgenv().Teleporting = true
        end)
    else 
        warn("Serverhop failed. Trying again in 2 minutes")

        task.wait(120)
        serverhop(_script)
    end 
end

return serverhop

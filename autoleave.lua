local Players = game:GetService("Players")

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

task.spawn(function()
	print('started')
    task.wait(20)
    game:Shutdown()
end)

local TeleportCheck = false

Players.LocalPlayer.OnTeleport:Connect(function(State)
	if (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/skiddyshit/autoleave/refs/heads/main/autoleave.lua'))()")
  end
end)

local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local RunService = game:GetService "RunService"

local Aserde = require(ReplicatedStorage.Shared.Alloy.Aserde)
local remote = ReplicatedStorage.aserdeTest

--local b = Aserde.CreateBuffer(table.create(1000, true))

--print("Size of the buffer:", buffer.len(b))

--task.wait(11)
--[[
for i = 1, 1000, 1 do
	task.wait(0.01)
	remote:FireClient(Players.M_at270, Aserde.CreateBuffer(table.create(1000, true)))
	--remote:FireClient(Players.M_at270, table.create(1000, true))
	--print "fired"
end]]

--[[print "Started"

local received = 0
remote.onServerEvent:Connect(function(plr, b)
	--b = Aserde.ReadBuffer(b)
	received += #b
end)

task.wait(25)

print("Received:", received)]]

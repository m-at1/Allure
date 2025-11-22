local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Aserde = require(ReplicatedStorage.Shared.Alloy.Aserde)
local remote = ReplicatedStorage.aserdeTest

local b = Aserde.CreateBuffer(table.create(1000, true))

print("Size of the buffer:", buffer.len(b))

task.wait(10)
--[[
for i = 1, 10000, 1 do
	task.wait(0.01)
	--remote:FireClient(Players.M_at270, b)
	--remote:FireClient(Players.M_at270, table.create(1000, true))
	print "fired"
end]]

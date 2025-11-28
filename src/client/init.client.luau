local ReplicatedStorage = game:GetService "ReplicatedStorage"
local RunService = game:GetService "RunService"
print "Hello world, from client!"

local Aserde = require(ReplicatedStorage.Shared.Alloy.Aserde)
--local Alloy = require(ReplicatedStorage.Shared.Alloy)

local b = Aserde.CreateBuffer { false, 8, -19, 3800 }

print("Created buffer length:", buffer.len(b))

local decoded = Aserde.ReadBuffer(b)

print("Decoded:", decoded)

--[[
task.wait(13)

print "Started"

local remote = ReplicatedStorage.aserdeTest

local sent = 0
local a = RunService.RenderStepped:Connect(function(delta: number)
	--remote:FireServer(Aserde.CreateBuffer(table.create(1000, true)))
	remote:FireServer(table.create(1000, true))
	sent += 1000
end)

task.wait(10)

a:Disconnect()

print("Sent:", sent)]]

-- TODO:
--[[
finish the other datatypes
]]

--[[
local trash = Alloy.garbage(Alloy, {})

local b = trash:State(1):setter(function(self, args)
	print(args)
end)

b(10)

partname = trash:State "Cool"
includeeffect = trash:State(true)

local camplified = trash:Amplify {
	Parent = workspace,
	Position = Vector3.new(0, 15, 0),

	--Name = partname .. "'s Part",

	--Anchored = includeeffect,

	trash:Effect(function(with, inner)
		if with(includeeffect) then
			return {
				Anchored = true,
				Name = "Is anchored!",
			}
		else
			return {
				Anchored = false,
				Name = "Is not anchored!",
			}
		end
	end),

	trash:Effect(function(with, _inner)
		--warn(includeeffect:get())
		if with(includeeffect) then
			warn "1"
			--[[return Alloy.onEvent "Touched"(function(self, ...)
				print(self, ...)
			end)
		else
			warn "2"
		end
		--[[return Alloy.onEvent "Touched"(function(self, ...)
			print("second", self, ...)
		end)
	end),
}

local c = trash:New "Part"(camplified)

task.wait(10)

--partname "April"

--task.wait(3)

camplified.Name = partname .. "!"

task.wait(3)

partname "John"

task.wait(3)

trash:mount(
	c,
	trash:Amplify {
		Name = "Overriden name!",
	}
)

task.wait(3)

includeeffect(false)

print "shared table now"

-- TODO: inner remote event, handler for it, shared amplified and rules]]

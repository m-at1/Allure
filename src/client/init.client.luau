local ReplicatedStorage = game:GetService "ReplicatedStorage"
local RunService = game:GetService "RunService"
print "Hello world, from client!"

local Aserde = require(ReplicatedStorage.Shared.Alloy.Aserde)
--local Alloy = require(ReplicatedStorage.Shared.Alloy)

--local c = Aserde.CreateBuffer

task.wait(10)

print "serializing"

local b = Aserde.CreateBuffer {
	A = Color3.fromRGB(36, 209, 209),
	J = { [Aserde.SpecialType] = "C", 288 },

	MyCFrame = CFrame.new(Vector3.new(19.80, 108.92328, 99.0923), Vector3.new(500, 120, 1203)),

	Vector2int16.new(99, 800),
	test = Vector3int16.new(17800, 28900, 800),
	mynewTable = { yeah = 1, thisone = { 52, 19, forsomereason = 10, bytheway = 10 } },
	true,
	bytheway = 59,
} --(MergeBuffer(c { a = true, 19, "Hello" }, c { false, "Yeah" })) --{ "Text", a = 1, b = 20, c = 1000, true }

print("Created buffer length:", buffer.len(b))

task.wait(3)

print "deserializing"

local decoded = Aserde.ReadBuffer(b)

print("Decoded:", decoded)

--TODO: rewrite alloy on the new typesolver

--TODO: technically aserde is done. make a cframe ser/des just in case
--TODO: protocols, shared amplified, 1 remote event for shared amplified, reliable and unreliable for protocols
--delete Boundary, make a new SharedAmplified and Protocol folders, expose some of Aserde functionality in the alloy table

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

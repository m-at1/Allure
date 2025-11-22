local ReplicatedStorage = game:GetService "ReplicatedStorage"
print "Hello world, from client!"

local Aserde = require(ReplicatedStorage.Shared.Alloy.Aserde)
local Alloy = require(ReplicatedStorage.Shared.Alloy)

local a = Aserde.CreateBuffer { 190, 800 }

print(a)

print("Size of the buffer:", buffer.len(a))

print("Reading:", Aserde.ReadBuffer(a))

task.wait(8)

-- TODO:
--[[
an excellent serializer is already done
basically can be heavily improved with deduplication
and finish it with the rest of dataTypes

create a deduplication metadata that defines
how many next bytes to read for the amount number
then the actual metadata itself
and the value itself

this can be optimized though like the metadata value + 100 < 0 then the actual value metadata is value-100 and the 100 implies deduplication (the amount
number are bytes before value-100 metadata byte)
or that's worse
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

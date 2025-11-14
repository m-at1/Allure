local ReplicatedStorage = game:GetService "ReplicatedStorage"
print "Hello world, from client!"

local Alloy = require(ReplicatedStorage["Shared"]["Alloy"])

local trash = Alloy.garbage(Alloy, {})

local b = trash:State(1):setter(function(self, args)
	print(args)
end)

b(10)

partname = trash:State "Cool"
includeeffect = trash:State(true)

local c = trash:New "Part" {
	Parent = workspace,
	Position = Vector3.new(0, 15, 0),

	Name = partname .. "'s Part",

	trash:Effect(function(with, _inner)
		--warn(includeeffect:get())
		if with(includeeffect) then
			--warn "1"
			return Alloy.onEvent "Touched"(function(self, ...)
				print(self, ...)
			end)
		end
		--warn "2"
		return Alloy.onEvent "Touched"(function(self, ...)
			print("second", self, ...)
		end)
	end),
}

task.wait(10)

partname "John"
includeeffect(false)

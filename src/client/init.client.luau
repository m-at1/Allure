local ReplicatedStorage = game:GetService "ReplicatedStorage"
print "Hello world, from client!"

local Alloy = require(ReplicatedStorage["Shared"]["Alloy"])

local trash = Alloy.garbage(Alloy, {})

local b = trash:State(1):setter(function(self)
	print "hi"
end)

b(10)

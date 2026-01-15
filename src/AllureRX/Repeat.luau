--!strict
local Promise = require(script.Parent.Parent["Promise"])
local Types = require "../Util/Types"
local Observable = require "./Observable"

return function(garbage: Types.garbage<any>, amount: number, ...: any)
	local next = Observable(garbage)
	local sequence = { ... }

	(function()
		return Promise.new(function(resolve, reject, onCancel)
			task.wait()

			for i = 1, amount do
				for _, j in sequence do
					next:emit(j)
					task.wait()
				end
			end

			next:close()
			resolve()
		end :: any)
	end)()

	return next
end

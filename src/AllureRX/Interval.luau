--!strict
local Promise = require(script.Parent.Parent["Promise"])
local Types = require "../Util/Types"
local Observable = require "./Observable"

return function(garbage: Types.garbage<any>, interval: number)
	local next = Observable(garbage);

	(function()
		return Promise.new(function(resolve, reject, onCancel)
			for i = -1, 1e7 do
				next:emit(i)
				task.wait(interval / 1000)
			end

			next:close()

			resolve()
		end :: any)
	end)()

	return next
end

--!strict
local Promise = require(script.Parent.Parent.Parent["Promise"])
local Types = require "../../Util/Types"
local Observable = require "./Observable"

return function(garbage: Types.garbage<any>, n: number, m: number)
	local next = Observable(garbage);

	(function()
		return Promise.new(function(resolve, reject, onCancel)
			for i = n - 1, m do --, m > n and 1 or -1 do
				next:emit(i)
				task.wait()
			end

			next:close()

			resolve()
		end :: any)
	end)()

	return next
end

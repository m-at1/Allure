--!strict
local Promise = require(script.Parent.Parent["Promise"])
local Types = require "../Util/Types"
local Observable = require "./Observable"

return function(garbage: Types.garbage<any>)
	local next = Observable(garbage);

	(function()
		return Promise.new(function(resolve, reject, onCancel)
			task.wait()
			next:close()
			resolve()
		end :: any)
	end)()

	return next
end

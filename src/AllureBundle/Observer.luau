--!strict

local UTIL = script.Parent.Parent.Util
local Types = require(UTIL.Types)

return function(trash: Types.garbage<unknown>, observedstate: Types.StateObject<any>): any
	local connections: { (...any?) -> ...any? } = {}

	local observer = {
		onBind = function(fn: (...any?) -> ...any?)
			fn(observedstate)
			observedstate:connect(fn)(fn :: any)

			connections[#connections] = fn

			return function()
				observedstate:connect(fn)(nil)
			end
		end,
		onChange = function(fn: (...any?) -> ())
			observedstate:connect(fn)(fn :: any)

			connections[#connections] = fn

			return function()
				observedstate:connect(fn)(nil)
			end
		end,
		_destroy = function(self)
			-- disconnect connections
			for _, fn in connections do
				observedstate:connect(fn)(nil)
			end

			--destroy
			self = nil :: any
		end,
	}

	table.insert(trash :: { any }, observer)

	return observer
end :: (
	trash: Types.garbage<unknown>
) -> { _destroy: () -> (), onBind: ((...any?) -> ()) -> () -> (), onChange: ((...any?) -> ()) -> () -> () }

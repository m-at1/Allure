--!strict

local main = script.Parent.Parent
local Types = require(main.Types)

return function(trash: Types.garbage<unknown>, observedstate: Types.StateObject<any>): any
	local observer = {
		onBind = function(fn)
			fn()
			observedstate:connect(fn)(fn :: any)

			return function()
				observedstate:connect(fn)(nil)
			end
		end,
		onChange = function(fn: () -> ())
			observedstate:connect(fn)(fn :: any)

			return function()
				observedstate:connect(fn)(nil)
			end
		end,
		_destroy = function(self)
			self.onBind = nil
			self.onChange = nil
		end,
	}

	table.insert(trash :: any, observer)

	return observer
end :: (
	trash: Types.garbage<unknown>
) -> { _destroy: () -> (), onBind: ((...any?) -> ()) -> () -> (), onChange: ((...any?) -> ()) -> () -> () }

--!strict

local main = script.Parent.Parent
local Types = require(main.Types)

return (
	function(event: string): any
		return function(fn: (self: Types.Amplified<unknown>) -> ...any)
			return { __kind = "onevent" :: "onevent", event = event, fn = fn } :: Types.SpecialValue<
				"onevent",
				{ ["fn"]: (self: Types.Amplified<unknown>) -> ...any? } & { ["event"]: string }
			>
		end
	end :: any
) :: Types.onEvent

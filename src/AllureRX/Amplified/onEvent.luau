--!strict

local UTIL = script.Parent.Parent.Parent.Util

local Types = require(UTIL.Types)

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

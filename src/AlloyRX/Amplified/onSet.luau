--!strict

local UTIL = script.Parent.Parent.Parent.Util

local Types = require(UTIL.Types)

return (
	function(prop: string): any
		return function(fn: (self: Types.Amplified<unknown>) -> ...any)
			return { __kind = "onset" :: "onset", prop = prop, fn = fn } :: Types.SpecialValue<
				"onset",
				{ ["fn"]: (self: Types.Amplified<unknown>) -> ...any? } & { ["prop"]: string }
			>
		end
	end :: any
) :: Types.onSet

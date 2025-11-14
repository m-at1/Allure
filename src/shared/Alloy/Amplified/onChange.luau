--!strict

local main = script.Parent.Parent

local Types = require(main.Types)

return (
	function(prop: string): any
		return function(fn: (self: Types.Amplified<unknown>) -> ...any)
			return { __kind = "onchange" :: "onchange", prop = prop, fn = fn } :: Types.SpecialValue<
				"onchange",
				{ ["fn"]: (self: Types.Amplified<unknown>) -> ...any? } & { ["prop"]: string }
			>
		end
	end :: any
) :: Types.onChange

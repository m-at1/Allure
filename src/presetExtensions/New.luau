--!strict

local main = script.Parent.Parent
local Types = require(main.Types)

local Amplify = require(main.Amplified.Amplified)
local mount = require(main.Amplified.mount)

return function(
	trash: Types.garbage<unknown>,
	object: string --propTable: {} | Types.Amplified<unknown>
): any
	return function(propTable: { [number | string]: any } | Types.Amplified<unknown>)
		-- case 1: propTable is a standard table
		-- Amplify will error if there's no table (however this may need further clarification)

		if not propTable._updaters and not propTable._states then
			propTable = Amplify(trash, propTable)
		end

		return mount(trash, Instance.new(object), propTable :: Types.Amplified<unknown>, nil, nil)
	end
end :: (
	trash: Types.garbage<unknown>,
	object: string
) -> (propTable: { [number | string]: any } | Types.Amplified<unknown>) -> Instance

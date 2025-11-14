--!strict

local main = script.Parent.Parent

local Types = require(main.Types)

return (
	function(trash: any, fn: (with: (...any) -> ...any, innertrash: Types.garbage) -> ()): any
		local effect = trash
			:State()
			:setter(nil)
			:custom "_trash"(trash:garbage() :: Types.Callable)
			:custom "_states"({})
			:getter(function(self)
				return self.__value
			end)

		local stateValues = function(...)
			local values = {}
			for _, v in pairs { ... } do
				values[#values + 1] = if v.get ~= nil then v:get() else v
			end
			return table.unpack(values)
		end

		local updatefn = function()
			effect._trash()
			effect.__value = fn(function(...)
				return stateValues(...)
			end, effect._trash)

			effect.__updater()
		end

		effect.__value = fn(function(...: any)
			for _, state in pairs { ... } do
				if not state.connect then
					continue
				end
				state:connect(updatefn)(updatefn)
				table.insert(effect._states, state)
			end

			return stateValues(...)
		end, effect._trash)

		return effect:deleter(function(self)
			for _, state in self._states do
				state:connect(updatefn)(nil)
			end
		end)
	end :: any
) :: (
	trash: Types.garbage<Types.Alloy & {} & any>,
	fn: (with: (...any) -> ...any, innertrash: Types.garbage) -> ()
) -> Types.StateObject<nil>

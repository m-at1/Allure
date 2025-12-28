--!strict

local UTIL = script.Parent.Parent.Util

local Types = require(UTIL.Types)

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

		local stateValues = function(...: Types.StateObject<any> | any)
			local values = {}
			for _, v in pairs { ... } do
				values[#values + 1] = if v.get ~= nil then (v :: Types.StateObject<any>):get() else v
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

		effect.__value = fn(function(...: any | Types.StateObject<unknown>)
			for _, state in pairs { ... } do
				if not state.connect then
					continue
				end
				state = state :: Types.StateObject<unknown>
				state:connect(updatefn)(updatefn)
				table.insert(effect._states :: any, state :: any) --horrid
			end

			return stateValues(...)
		end, effect._trash)

		return effect:deleter(function(self: Types.StateObject<any> & { _states: any })
			for _, state in self._states do
				state:connect(updatefn)(nil)
			end
		end)
	end :: any
) :: (
	trash: Types.garbage<Types.Allure & {} & any>,
	fn: (with: (...any) -> ...any, innertrash: Types.garbage) -> ()
) -> Types.StateObject<nil>

--!strict

local UTIL = script.Parent.Parent.Util
local Types = require(UTIL.Types)

return (
	function(trash: any, fn: (with: (...any) -> ...any, innertrash: Types.garbage) -> ()): any
        --stylua: ignore
		local computed = trash
			:State()
			:setter(nil)
			:custom "_trash" (trash:garbage() :: Types.Callable)
			:custom "connectedvalues"({} :: {[Types.StateObject<any>]: any}) --{[stateobject]: any?}
			:getter(function(self)
				if self.__value == nil then
					self.__value = fn(function(...: any)
						local values = {}

						for _, state in pairs { ... } do
							local val = state:get()
							self.connectedvalues[state] = val
						end

						for _, v in pairs { ... } do
							v = self.connectedvalues[v]
							values[#values + 1] = v
						end
						return table.unpack(values)
					end, self._trash)

					self.__updater()
					return self.__value
				end

				for state: Types.State<any>, value in self.connectedvalues do
					if value ~= state:get() then
						--update values
						for st: Types.State<any>, _ in self.connectedvalues do
							self.connectedvalues[st] = st:get()
						end

						--update value
						getmetatable(self._trash :: any).__call()

						self.__value = fn(function(...)
							local values = {}
							for _, v in pairs { ... } do
								v = self.connectedvalues[v]
								values[#values + 1] = v
							end
							return table.unpack(values)
						end, self._trash)

						--returns because 1 value mismatch minimal
						self.__updater()
						return self.__value
					end
				end

				return self.__value
			end)

		return computed
	end :: any
) :: (
	trash: Types.garbage<Types.Allure & {} & any>,
	fn: (with: (...any) -> ...any, innertrash: Types.garbage) -> ()
) -> Types.StateObject<nil>

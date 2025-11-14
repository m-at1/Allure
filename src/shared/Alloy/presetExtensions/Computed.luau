--!strict

local main = script.Parent.Parent
local Types = require(main.Types)

return (
	function(trash: any, fn: (with: (...any) -> (), innertrash: Types.garbage) -> ()): any
        --stylua: ignore
		local computed = trash
			:State()
			:setter(nil)
			:custom "_trash" (trash:garbage() :: Types.Callable)
			:custom "connectedvalues"({}) --{[stateobject]: any?}
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

				for state: Types.StateObject<unknown>, value in self.connectedvalues do
					if value ~= state:get() then
						--update values
						for st, _ in self.connectedvalues do
							self.connectedvalues[st] = st:get()
						end

						--update value
						getmetatable(self._trash).__call()

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
	trash: Types.garbage<Types.Alloy & {} & any>,
	fn: (with: (...any) -> (), innertrash: Types.garbage) -> ()
) -> Types.StateObject<nil>

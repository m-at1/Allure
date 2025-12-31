--!strict

local UTIL = script.Parent.Parent.Util
local Types = require(UTIL.Types)

return (
	function(trash: any, FIFO: boolean): any
		return trash
			:State()
			:setter(nil)
			:custom "_stack"({})
			:custom "push"(function(self: Types.StateObject<any> & { _stack: {} }, value: any)
			local _T = table.clone(self._stack) :: any
			for k, v in _T do
				self._stack[k + 1] = v
			end
			self._stack[1] = value
		end)
			:custom "pop"(function(self: Types.StateObject<any> & { _stack: {} })
			if not FIFO then
				self.__value = self._stack[1]
				self._stack[1] = nil

				-- reorder
				local _T = table.clone(self._stack) :: any
				for k, v in _T do
					self._stack[k - 1] = v
				end
			else --LIFO
				self.__value = self._stack[#self._stack]
				self._stack[#self._stack] = nil
			end
			self:updater()
		end)
	end :: any
) :: (trash: Types.garbage<Types.Allure & {} & any>, FIFO: boolean) -> Types.StateObject<any>

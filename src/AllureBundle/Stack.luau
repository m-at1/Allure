--!strict

local UTIL = script.Parent.Parent.Util
local Types = require(UTIL.Types)

return (
	function(trash: any, FIFO: boolean, length: number?): any
		local ratelimit = {
			amount = 99999,
			per = 99999,

			val = 0,
			lasttime = 0,
		}

		return trash
			:State()
			:custom "_stack"({})
			:custom "ratelimit"(function(self: Types.StateObject<any>, amount: number, perSeconds: number)
			ratelimit.amount = amount
			ratelimit.per = perSeconds
			return self
		end)
			:custom "push"(function(self: Types.StateObject<any> & { _stack: {} }, value: any)
			-- length
			if #self._stack >= (length and length or 99999) then
				return
			end

			--ratelimits
			local ct = time()
			if ratelimit.lasttime + ratelimit.per < ct then
				ratelimit.lasttime = ct
				ratelimit.val = 0
			end
			if ratelimit.val >= ratelimit.amount then
				return
			end

			--push
			local _T = table.clone(self._stack) :: any
			for k, v in _T do
				self._stack[k + 1] = v
			end

			self._stack[1] = value
			ratelimit.val += 1
		end)
			:custom "pop"(function(self: Types.StateObject<any> & { _stack: {} })
			if not FIFO then
				--self.__value = self._stack[1]
				self(self._stack[1]) --adapt for setters
				self._stack[1] = nil

				-- reorder
				local _T = table.clone(self._stack) :: any
				for k, v in _T do
					self._stack[k - 1] = v
				end
			else --LIFO
				--self.__value = self._stack[#self._stack]
				self(self._stack[#self._stack]) ---adapt for setters
				self._stack[#self._stack] = nil
			end
			--self:updater()
		end)
	end :: any
) :: (trash: Types.garbage<Types.Allure & {} & any>, FIFO: boolean, length: number?) -> Types.StateObject<any>

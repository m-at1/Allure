--!strict
--#selene: allow(shadowing)

local UTIL = script.Parent.Parent.Parent.Util
local Log = require(UTIL.Log)
local Types = require(UTIL.Types)

-- Crossdirectory: Effect used by State metamethods
local Effect = nil :: any
if script.Parent.Parent.Parent:FindFirstChild "AllureBundle" then
	Effect = require(script.Parent.Parent.Parent.AllureBundle.Effect)
end

function StateConstructor(trash: any, initialvalue: unknown): any
	if typeof(trash) ~= "table" then
		Log.logError("AllureRX", "noGarbage", "...:State(...)")
	end

	local self: Types.State<unknown> = { __value = initialvalue } :: Types.State<unknown>

	self.__getter = function()
		return self.__value
	end

	self.__setter = function(args)
		if self.__value == args :: any then
			return self.__value
		end
		self.__value = args

		self.__updater(self.connections)
		return self.__value
	end

	self.__updater = function(a: { [any]: (any) -> ...any? })
		for _, f in a do
			if f then
				f(self)
			end --<<< here self:updater
		end
	end

	self.__deleter = function()
		self = self :: any --(setmetatable(self, nil) :: any) :: (any | {any})
		self.connections = {}
		self.__customs = {}

		--self = nil
	end

	self.__customs = {} :: { [string]: any? }
	self.connections = {} :: { [any]: (any) -> ...any? }

	table.insert(trash :: { any }, self :: Types.trashable)

	self.get = function(self)
		--return if self.__getter ~= nil then self.__getter() else nil
		return self.__getter()
	end

	self.getter = function(self: Types.State<unknown>, fn: (self: Types.State<unknown>) -> any?): Types.State<unknown>
		self.__getter = function()
			return fn(self)
		end
		return self
	end

	self.setter = function(
		self: Types.State<unknown>,
		fn: nil | (self: Types.State<unknown>, val: any?) -> ...any?
	): Types.State<unknown>
		self.__setter = function(val): ...any?
			if not fn then
				return self.__value
			end
			return fn(self, val)
		end
		return self
	end

	self.updater = function(self, fn: (self: Types.State<unknown>, fn2: (any) -> ...any?) -> any?)
		if not fn then
			self.__updater(self.connections)
			return self
		end

		self.__updater = function()
			for _, f in pairs(self.connections :: { [any]: (any) -> ...any? }) do
				fn(self, f)
			end
		end
		return self
	end

	self.deleter = function(self: Types.State<unknown>, fn: (self: Types.State<unknown>) -> any?): Types.State<unknown>
		self.__deleter = function()
			fn(self)
			--self = setmetatable(self, nil)
			self.connections = nil :: any
			self.__customs = nil :: any
			self = nil :: any
		end
		return self
	end

	self.custom = function(self: Types.State<unknown>, name: string): (fn: any?) -> Types.State<unknown>
		return function(fn: any? | (self: Types.State<unknown>, val: any?) -> any?)
			self.__customs[name] = fn

			--print(self.__customs)

			return self
		end
	end

	self.connect = function(
		self: Types.State<unknown>,
		name: any?
	): (fn: nil | (...any?) -> () | any?) -> Types.State<unknown>
		return function(fn: nil | (...any?) -> () | any?)
			if name == nil then
				name = fn
			end

			self.connections[name :: any] = fn

			return self
		end
	end

	local newself = (
		setmetatable(self :: Types.State<unknown>, {
			__index = self.__customs,
			__call = function(self, args)
				return self.__setter(args)
			end,
		}) :: any
	) :: Types.StateObject<unknown, typeof(self.__customs)>

	--Crossdirectory presets
	if Effect then
		local nmt = getmetatable(newself)

		-- preset effect extensions
		nmt.__concat = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) .. (with(value) :: any)
			end)
		end
		nmt.__unm = function(table)
			return Effect(trash, function(with, _)
				return -with(table)
			end)
		end
		nmt.__add = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) + (with(value) :: any)
			end)
		end
		nmt.__sub = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) - (with(value) :: any)
			end)
		end
		nmt.__mul = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) * (with(value) :: any)
			end)
		end
		nmt.__div = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) / (with(value) :: any)
			end)
		end
		nmt.__idiv = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) // (with(value) :: any)
			end)
		end
		nmt.__mod = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) % (with(value) :: any)
			end)
		end
		nmt.__pow = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) ^ (with(value) :: any)
			end)
		end

		nmt.__eq = function(table, value)
			return Effect(trash, function(with, _): any
				return (with(table) :: any) == (with(value) :: any)
			end)
		end
		nmt.__lt = function(table, value)
			return Effect(trash, function(with, _): any
				return (with(table) :: any) < (with(value) :: any)
			end)
		end
		nmt.__le = function(table, value)
			return Effect(trash, function(with, _): any
				return (with(table) :: any) <= (with(value) :: any)
			end)
		end
	end

	return newself
end

return (StateConstructor :: any) :: Types.StateConstructor

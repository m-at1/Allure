--!strict
--#selene: allow(shadowing)

local main = script.Parent.Parent
local Log = require(main.Log)
local Types = require(main.Types)

local Effect = require(main.presetExtensions.Effect)

function StateConstructor(trash: any, initialvalue: unknown): any
	if typeof(trash) ~= "table" then
		Log.logError("noGarbage", "...:State(...)")
	end

	local self: Types.State<unknown> = { __value = initialvalue } :: Types.State<unknown>

	self.__getter = function()
		return self.__value
	end

	self.__setter = function(args)
		if self.__value == args then
			return self.__value
		end
		self.__value = args

		self.__updater(self.connections)
		return self.__value
	end

	self.__updater = function()
		for _, f in self.connections do
			if f then
				f(self)
			end --<<< here self:updater
		end
	end

	self.__deleter = function()
		self = setmetatable(self, nil)
		self.connections = {}
		self.__customs = {}

		--self = nil
	end

	self.__customs = {}
	self.connections = {}

	table.insert(trash, self :: Types.trashable)

	self.get = function(self)
		return if self.__getter ~= nil then self.__getter() else nil
	end

	self.getter = function(self: Types.State<unknown>, fn: (self: Types.State<unknown>) -> any?): Types.State<unknown>
		self.__getter = function()
			return fn(self)
		end
		return self
	end

	self.setter = function(
		self: Types.State<unknown>,
		fn: nil | (self: Types.State<unknown>, val: any?) -> any?
	): Types.State<unknown>
		self.__setter = function(val)
			if not fn then
				return self.__value
			end
			return fn(self, val)
		end
		return self
	end

	self.updater = function(self, fn: nil | (self: Types.State<unknown>, fn2: nil | (any?) -> any) -> any?)
		if not fn then
			self.__updater(self.connections)
			return self
		end

		self.__updater = function()
			for _, f in self.connections do
				fn(self, f)
			end
		end
		return self
	end

	self.deleter = function(self: Types.State<unknown>, fn: (self: Types.State<unknown>) -> any?): Types.State<unknown>
		self.__deleter = function()
			fn(self)
			self = setmetatable(self, nil)
			self.connections = {}
			self.__customs = {}
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

	self.connect = function(self: Types.State<unknown>, name: any?): (fn: nil | (any?) -> any?) -> Types.State<unknown>
		return function(fn: nil | (any?) -> any?)
			if name == nil then
				name = fn
			end

			self.connections[name :: any] = fn

			return self
		end
	end

	local newself = setmetatable(self :: Types.State<unknown>, {
		__index = self.__customs,
		__call = function(self, args)
			return self.__setter(args)
		end,

		-- preset effect extensions
		__concat = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any .. with(value) :: any
			end)
		end,
		__unm = function(table)
			return Effect(trash, function(with, _)
				return -with(table)
			end)
		end,
		__add = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any + with(value) :: any
			end)
		end,
		__sub = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any - with(value) :: any
			end)
		end,
		__mul = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any * with(value) :: any
			end)
		end,
		__div = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any / with(value) :: any
			end)
		end,
		__idiv = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any // with(value) :: any
			end)
		end,
		__mod = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any % with(value) :: any
			end)
		end,
		__pow = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any ^ with(value) :: any
			end)
		end,

		__eq = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any == with(value) :: any
			end)
		end,
		__lt = function(table, value)
			return Effect(trash, function(with, _)
				return (with(table) :: any) < with(value) :: any
			end)
		end,
		__le = function(table, value)
			return Effect(trash, function(with, _)
				return with(table) :: any <= with(value) :: any
			end)
		end,
	}) :: Types.StateObject<unknown, typeof(self.__customs)>

	return newself
end

return (StateConstructor :: any) :: Types.StateConstructor

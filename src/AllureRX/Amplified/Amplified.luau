--!strict

--# selene: allow(shadowing)

local UTIL = script.Parent.Parent.Parent.Util

local Util = require "../../Util"
local Log = require(UTIL.Log)
local Types = require(UTIL.Types)

function constructor<T>(trash: any, initialvalue: T & { [any]: any }): any
	if typeof(trash) ~= "table" then
		Log.logError("noGarbage", "...:Amplified {}")
	end
	if typeof(initialvalue) ~= "table" then
		Log.logError("AllureRX", "amplifiedTable")
	end

	local self: Types._AMP<unknown, {}> = {} :: Types._AMP<unknown, {}>

	self.__value = {} :: { [any]: any }

	self.__getter = function()
		return self.__value
	end

	self.__setter = function(args: T)
		if self.__value == args :: any then
			return self.__value
		end
		self.__value = args

		self.__updater(self.connections)
		return self.__value
	end

	self.__updater = function(k, v) --a: { [any]: (self: Types.Amplified<unknown>, k: any, v: any) -> ...any? }
		for _, f in self.connections do
			if f then
				f(self :: any, k, v)
			end --<<< here self:updater
		end
	end

	self._updaters = {}

	self.__deleter = function()
		--self = setmetatable(self, nil)
		self.connections = {}
		self.__customs = {}
		self._updaters = {}

		self = nil :: any
	end

	self.__customs = {} :: { [string]: any? }
	self.connections = {} :: { [any]: (any) -> ...any? }

	self._states = {}
	self._onsets = {} --[string]: {functions}

	table.insert(trash :: { any }, self)

	self.get = function(self)
		--return if self.__getter ~= nil then self.__getter() else nil
		return self.__getter()
	end

	self.getter = function(
		self: Types.Amplified<unknown>,
		fn: (self: Types.Amplified<unknown>) -> any?
	): Types.Amplified<unknown>
		self.__getter = function()
			return fn(self)
		end
		return self
	end

	self.setter = function(
		self: Types.Amplified<unknown>,
		fn: nil | (self: Types.Amplified<unknown>, val: T) -> ...any?
	): Types.Amplified<unknown>
		self.__setter = function(val: T)
			if not fn then
				return self.__value
			end
			return fn(self, val) :: {}
		end
		return self
	end

	self.updater = function(
		self: Types.Amplified<unknown>,
		fn: (
			self: Types.Amplified<unknown>,
			fn2: (self: Types.Amplified<unknown>, k: any, v: any) -> ...any?
		) -> any?
	)
		if not fn then
			self.__updater(self.connections)
			return self
		end

		self.__updater = function(
			--a: { [any]: (self: Types.Amplified<unknown>, k: any, v: any) -> ...any? },
			k: any,
			v: any
		)
			for _, f in pairs(self.connections) do
				fn(self, f)
			end
			return 1
		end
		return self
	end

	self.deleter = function(
		self: Types.Amplified<unknown>,
		fn: (self: Types.Amplified<unknown>) -> any?
	): Types.Amplified<unknown>
		self.__deleter = function()
			fn(self)
			--self = setmetatable(self, nil)
			self.connections = nil :: any
			self.__customs = nil :: any
			self._updaters = nil :: any
			self = nil :: any
		end
		return self
	end

	self.custom = function(self: Types.Amplified<unknown>, name: string): (fn: any?) -> Types.Amplified<unknown>
		return function(fn: any? | (self: Types.Amplified<unknown>, val: any?) -> any?)
			self.__customs[name] = fn

			--print(self.__customs)

			return self
		end
	end

	self.connect = function(
		self: Types.Amplified<unknown>,
		name: any?
	): (
		fn: nil | (self: Types.Amplified<unknown>, k: any, v: any) -> () | any?
	) -> Types.Amplified<unknown>
		return function(fn: nil | (self: Types.Amplified<unknown>, k: any, v: any) -> () | any?)
			if name == nil then
				name = fn
			end

			self.connections[name] = fn

			return self
		end
	end

	local newself = nil :: any

	local ___nindex = function(_, k, v)
		-- case 3: if v was a state/different state, disconnect it
		if rawget(self._states, k) then
			rawget(self._states :: any, k):connect(self._updaters[k])(nil)
			rawget(self._states :: any, k)[k] = nil
		end
		self._updaters[k] = nil
		----rawget(self._states :: any, k)[k] = nil
		--self._states[k] = nil

		for _, st in self._onsets do
			st[k] = nil
		end

		local function nestval(key, val: { [any]: any })
			-- case 1, if v is amplified table
			-- case 2, if v is a state
			if typeof(val) == "table" and (val._updaters or (val.connections and not val.__kind)) then
				val = val :: any
				-- will turn it into a table

				--warn "here";
				(self.__value :: any)[key] = val:get()

				--nestval() was here!

				self._states[key] = val :: any

				self._updaters[key] = function()
					--warn("test", key, val, val:get())
					nestval(key, val:get())
				end
				val:connect(self._updaters[key])(self._updaters[key])

				--FIXME: this line halts thread for observables and does not assign them to _states
				--HACK: i just placed it into the end shouldnt really bug that much lol
				nestval(key, val:get())
				return

			-- case 6, if v is a function
			elseif typeof(val) == "function" then
				nestval(key, val(self))

				-- case 4, if v is an onChange event that can be handled inside of the amplified
			elseif typeof(val) == "table" and val.__kind == "onset" then
				self._onsets[val.prop] = self._onsets[val.prop] or {}
				self._onsets[val.prop][key] = val.fn
				-- onevent and onchange can only be handled by alloy.mount so they are forward passed

				-- case 5, if its anything else: instance, number, vector3, etc.
			else
				(self.__value :: any)[key] = val
				self.__updater(key :: any, val)
				if self._onsets[key] then
					for _, j in self._onsets[key] do
						j(self)
					end
				end
			end
		end

		nestval(k, v)

		--self.__updater(k::any, v)
	end

	newself = setmetatable({}, {
		__index = self,
		__newindex = ___nindex,
	})

	setmetatable(self._states :: any, { --__value
		__index = self.__value, --__customs
	})

	setmetatable(self.__value :: any, { --__customs
		__index = self.__customs, --_states
	})

	-- OLD: __value --> __customs --> _states
	-- NEW: _states --> __value --> __customs

	setmetatable(self, {
		__index = self._states, --self.__value --self.__customs,
		__newindex = self.__value,
	})

	local next__order: any = {}

	for k, v in pairs(initialvalue) do
		--newself[k] = v
		if typeof(v) == "table" and not v._updaters and not v.__value and not v.connections and not v.fn then
			next__order[k] = v
			continue
		end
		___nindex(nil, k :: any, v)
	end

	-- // ORDERING
	repeat
		local _nx: any = Util.deepClone(next__order)
		next__order = {}

		for _, v0 in ipairs(_nx) do
			for k, v in pairs(v0) do
				if typeof(v) == "table" and not v._updaters and not v.__value and not v.connections and not v.fn then
					next__order[k] = v
					continue
				end
				___nindex(nil, k :: any, v)
			end
		end

		task.wait()
	until #next__order == 0

	return newself
end

return (constructor :: any) :: Types.AmplifiedConstructor

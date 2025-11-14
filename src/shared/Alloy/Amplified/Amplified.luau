--!strict
--# selene: allow(shadowing)

local main = script.Parent.Parent
local Log = require(main.Log)
local Types = require(main.Types)

function constructor(trash: any, initialvalue: { [unknown]: unknown }): any
	if typeof(trash) ~= "table" then
		Log.logError("noGarbage", "...:Amplified {}")
	end
	if typeof(initialvalue) ~= "table" then
		Log.logError("amplifiedTable")
	end

	local self: Types.Amplified<unknown, {}> = {} :: Types.Amplified<unknown, {}>

	self.__value = {} :: { [any]: any }

	self.__getter = function()
		return self.__value
	end

	self.__setter = function(args)
		if self.__value == args then
			return self.__value
		end
		self.__value = args :: {}

		self.__updater(self.connections)
		return self.__value
	end

	self.__updater = function(k: any, v: any)
		for _, f in self.connections do
			if f then
				f(self, k, v)
			end --<<< here self:updater
		end
		return 1
	end

	self._updaters = {}

	-- this looks like hell but works like heaven
	self.__deleter = function()
		self = setmetatable(self, nil)
		self.connections = {}
		self.__customs = {}
		self._updaters = {}

		--self = nil
	end

	self.__customs = {}
	self.connections = {}
	self.__events = {}
	self._states = {}
	self.__enumerated = {}
	self.__children = {}
	self._onsets = {} --[string]: {functions}

	table.insert(trash, self)

	self.get = function(self)
		return if self.__getter ~= nil then self.__getter() else nil
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
		fn: nil | (self: Types.Amplified<unknown>, val: any?) -> any?
	): Types.Amplified<unknown>
		self.__setter = function(val)
			if not fn then
				return self.__value
			end
			return fn(self, val)
		end
		return self
	end

	self.updater = function(self, fn: nil | (self: Types.Amplified<unknown>, fn2: nil | (any?) -> any) -> any?)
		if not fn then
			self.__updater(self.connections)
			return self
		end

		self.__updater = function()
			for _, f in self.connections do
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
			self = setmetatable(self, nil)
			self.connections = {}
			self.__customs = {}
			self._updaters = {}
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
	): (fn: nil | (...any?) -> any?) -> Types.Amplified<unknown>
		return function(fn: nil | (any?) -> any?)
			if name == nil then
				name = fn
			end

			self.connections[name :: any] = fn

			return self
		end
	end

	local newself
	newself = setmetatable({}, {
		__index = self,
		--[[__newindexa = function(_, k, v)
				-- exists an updater and previous value is state
				if self._updaters[k] and (typeof((self.__value :: any)[k])=="table" and (self.__value :: any)[k].__value) then
					(self.__value :: any)[k]:connect(self._updaters[k])(nil)
				end

				rawset(self.__value, k, v)
				--self.__enumerated[k]=v 
				
				-- exists an updater and previous value is not state (table excluded)
				if self._updaters[k] and (self.__value :: any)[k] and not (typeof((self.__value :: any)[k])=="table" and (self.__value :: any)[k].__value) then
					self._updaters[k](self, k, v)
				end
				
				
				
				if typeof(v)=="table" and v.__value and typeof(k) == "string" then
					k = k :: string
					if self._updaters[k] then
						Log.logError("amplifiedDoubleConnection", k)
					end
					self._updaters[k] = function()		--the only time the function is initialized
						rawset(self.__value, k, v)		--setting it to states ; value-only is via alloy.mount
						self.__enumerated[k]=v:get()	--value-only
						self.__updater(k, v) 
						--warn("got an update")
						--...
					end
					
					self._updaters[k]()
					v:connect(self._updaters[k])(self._updaters[k])
				elseif typeof(v)=="table" and v.__value and typeof(k) == "number" then
					

				elseif typeof(k)=="number" and typeof(v)=="table" and v.__kind then
					
					warn(v.prop, self._updaters)
					
					local _ = 1
					
					(v.__kind=="onchange" and (function() 
						if self._updaters[v.prop] then
							Log.logError("amplifiedDoubleConnection", v.prop)
						end
						self._updaters[v.prop] = v.fn
						
					end)
							
						or 
					(v.__kind=="onevent" and (function()
						self.__events[v.event] = v.fn	
					end) 
						or 
					(v.__kind=="lifetime" and (function()
						--TODO		
					end)
						or function()
							print("niche")
					end)))()
				elseif typeof(k)~="string" and typeof(v) == "Instance" then
					self.__children[#self.__children+1] = v
					self.__updater(k, v) 
					
				elseif typeof(k) == "string" then
					self.__enumerated[k]=v
				elseif typeof(v) == "function" then
					warn "here"
				end
			end,]]

		__newindex = function(_, k, v)
			-- case 3: if v was a state/different state, disconnect it
			if self._states[k] then
				self._states[k]:connect(self._updaters[k])(nil)
			end
			self._updaters[k] = nil
			self._states[k] = nil
			for _, st in self._onsets do
				st[k] = nil
			end

			local function nestval(key, val)
				-- case 1, v is amplified table
				if typeof(val) == "table" and (val._updaters or (v.custom and v.updater and not v.__kind)) then
					-- will turn it into a table

					(self.__value :: any)[key] = val:get()
					self._states[key] = val :: any
					self._updaters[key] = function()
						nestval(key, val:get())
					end
					val:connect(self._updaters[key])(self._updaters[key])
					return

					--[[ case 2, v is a state
				elseif typeof(v) == "table" and v.custom and v.updater and not v.__kind then
					-- will turn it into the value

					(self.__value :: any)[key] = v:get()
					self._states[key] = v :: any
					self._updaters[key] = function()
						nestval(key, v:get())
					end
					v:connect(self._updaters[key])(self._updaters[key])
					return]]

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
							j(newself)
						end
					end
				end
			end

			nestval(k, v)

			--self.__updater(k::any, v)
		end,
	})

	setmetatable(self, {
		__index = self.__value, --self.__customs,
		__newindex = self.__value,
	})

	setmetatable(self.__value :: any, {
		__index = self.__customs,
	})

	setmetatable(self.__customs :: any, {
		__index = self._states,
	})

	for k, v in initialvalue do
		newself[k] = v
	end

	return newself
end

return (constructor :: any) :: Types.AmplifiedConstructor

--!strict

local main = script.Parent.Parent
local State = require "../State/State"
local Log = require(main.Log)
local Types = require(main.Types)

function curry(fn, x)
	return function(...)
		fn(x, ...)
	end
end

local ObservableConstructor = nil :: any

ObservableConstructor = function(garbage: Types.garbage<any>): Types.Observable
	local Observable = {
		connections = {} :: {
			[any]: (...any?) -> ...any?,
		},
		--_onclose = nil :: nil | (...any?) -> ...any?,
	}

	local _onclose: { [any]: any } = {}

	local STATUS = true --bool

	local _BIND_TO_CLOSE = false

	--[[
		The observable filters.
		Return () to avoid emission.
	]]
	local filters: (...any?) -> ...any? = function(...)
		return ...
	end :: (...any?) -> ...any?

	table.insert(garbage, function()
		Observable.connections = {}
		Observable.emit = nil :: any
		Observable = nil :: any
	end)

	Observable.connect = function(self: any, name: any?)
		return function(fn: nil | (...any?) -> ...any?)
			Observable.connections[name] = fn

			return Observable
		end
	end :: (self: any, name: any?) -> (nil | (...any?) -> ...any?) -> Types.Observable

	Observable.BindToClose = function(self: any)
		_BIND_TO_CLOSE = true
		return Observable
	end

	local emissionval = function()
		return
	end

	local function emission(...)
		if select("#", ...) == 0 or not Observable then
			return Observable
		end

		for _, fn in Observable.connections do
			fn(...)
		end

		if _BIND_TO_CLOSE then
			Observable:close()
		end

		return Observable
	end

	Observable.emit = function(self: any, ...: any?)
		local _a = { ... }
		emissionval = function()
			return table.unpack(_a)
		end

		return emission(filters(...))
	end

	--- Test
	Observable.onclose = function(self: any, name: any)
		return function(fn: nil | (...any?) -> ...any?)
			_onclose[name or fn] = fn
			return Observable
		end
	end

	Observable.close = function(self: any)
		if not STATUS then
			return
		end
		STATUS = false
		for _, fn in _onclose do
			fn()
		end
		Observable.connections = {}
		Observable.emit = nil :: any
		--emission = nil :: any
		--filters = nil :: any
		Observable = nil :: any
	end

	Observable.subscribe = function(self: any, fn: (...any?) -> ...any?)
		Observable:connect(fn)(fn)
		return Observable
	end

	Observable.unsubscribe = function(self: any, fn: (...any?) -> ...any?)
		Observable:connect(fn)(nil)
		return Observable
	end

	--observable operators
	Observable.pipe = function(self: Types.Observable)
		local new: Types.Observable = ObservableConstructor(garbage)

		local fn: any = nil
		fn = function(...)
			if not new or not new.emit then
				self:unsubscribe(fn)
				return
			end
			new:emit(...)
		end

		self:subscribe(fn)

		return new
	end

	--transformation
	Observable.take = function(self: Types.Observable, amount: number)
		local _filters = filters

		filters = function(...): ...any?
			if amount <= 1 then
				--Observable:close()
				_BIND_TO_CLOSE = true
				--return _filters(...)
			end
			amount -= 1

			return _filters(...)
		end

		return self
	end

	Observable.last = function(self: Types.Observable)
		local _filters = filters

		_onclose[{}] = function()
			emission(filters(emissionval()))
		end

		filters = function(...): ...any?
			if not STATUS then
				return _filters(...)
			else
				_filters(...)
			end
			return
		end

		return self
	end

	Observable.timeout = function(self: Types.Observable, time: number)
		local _filters = filters
		local begin = tick()

		filters = function(...): ...any?
			if tick() - begin >= time then
				Observable:close()
				return
			end
			begin = tick()

			return _filters(...)
		end

		return self
	end

	Observable.delay = function(self: Types.Observable, time: number)
		local _filters = filters

		filters = function(...): ...any?
			task.wait(time)
			return _filters(...)
		end

		return self
	end

	Observable.map = function(self: Types.Observable, fn: (...any?) -> ...any?)
		local _filters = filters
		filters = function(...): ...any?
			return fn(_filters(...))
		end
		return self
	end

	Observable.scan = function(self: Types.Observable, fn: (item: any?, result: any) -> ...any?)
		local _filters = filters

		local res = nil

		filters = function(...): ...any?
			res = fn(_filters(...), res)
			return res
		end
		return self
	end

	Observable.filter = function(self: Types.Observable, fn: (...any?) -> boolean)
		local _filters = filters
		filters = function(...): ...any?
			if not fn(_filters(...)) then
				return
			end

			return _filters(...)
		end
		return self
	end

	Observable = setmetatable(Observable, {
		__call = curry(Observable.emit, Observable),
	}) :: Types.Observable

	return Observable
end

return ObservableConstructor

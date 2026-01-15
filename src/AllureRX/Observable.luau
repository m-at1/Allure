--!strict

-- This realization requires STATES and AllureUI
-- EDIT: Reoptimize it because this is bloat
local State = require "../AllureUI/State/State"
local Promise = require(script.Parent.Parent["Promise"])
local Types = require(script.Parent.Parent.Util.Types)

-- Crossdirectory: Effect used by State metamethods
local Effect = nil :: any
if script.Parent.Parent:FindFirstChild "AllureBundle" then
	Effect = require(script.Parent.Parent.AllureBundle.Effect)
end

function curry(fn, x)
	return function(...)
		fn(x, ...)
	end
end

function last_apply(fn)
	return function(x, ...)
		fn(...)
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
	Observable._filter = function(a)
		return a
	end

	Observable.__customs = {}

	table.insert(garbage, function()
		Observable.connections = {}
		Observable.emit = nil :: any
		Observable = nil :: any
	end)

	--[[
		Connects `fn` to `name` key to be fired upon each emission of the Observable.
	]]
	Observable.connect = function(self: any, name: any?)
		return function(fn: nil | Types.STATE | (...any?) -> ...any?)
			if name == nil then
				name = fn
			end

			--[[if fn and typeof(fn) ~= "function" then
				(fn.connect :: any)(fn)(function()
					Observable:emit((fn.get :: any)(fn))
				end)
				return Observable
			end]]

			if fn and typeof(fn) ~= "function" then
				--(fn.connect :: any)(fn)(function()
				Observable.connect(fn)(function()
					--self.__setter((fn.get :: any)(fn))
					(fn :: any).__setter(Observable:get())
				end)
				return Observable
			end

			Observable.connections[name] = fn

			return Observable
		end
	end :: (self: any, name: any?) -> (nil | Types.STATE | (...any?) -> ...any?) -> Types.Observable

	Observable.custom = function(self: Types.Observable, name: string): (fn: any?) -> Types.Observable
		return function(fn: any? | (self: Types.Observable, val: any?) -> any?)
			self.__customs[name] = fn

			return self
		end
	end

	--[[
		Binds observable closure to the next emission regardless of what it is.
	]]
	Observable.BindToClose = function(self: any)
		_BIND_TO_CLOSE = true
		return Observable
	end

	--[[
		The number of scheduled required emissions that should be fired before full closure.
	]]
	local EMISSIONS: Types.StateObject<number> = State(garbage, 0)

	--[[
		Binds a function to whenever all of the scheduled emissions are fired.
	]]
	Observable.BindToLastEmission = function(self: any, fn: () -> ())
		if EMISSIONS:get() == 0 then
			fn()
		else
			local fn2: any
			fn2 = function(self: any)
				if self:get() == 0 then
					fn()
					EMISSIONS:connect(EMISSIONS)(nil)
				end
				return self:get()
			end
			EMISSIONS:connect(EMISSIONS)(fn2)
		end
	end

	--[[
		Generalized function of emission: to call each connection.
	]]
	local function emission(item): any
		-- if not item or not observable
		if not Observable then
			return Observable
		end

		Observable.__value = item

		for _, fn in Observable.connections do
			fn(Observable, item)
		end

		if _BIND_TO_CLOSE then
			Observable:close()
		end

		return Observable
	end

	Observable.__value = nil
	Observable.__setter = emission

	Observable.get = function(self: any)
		return Observable.__value
	end

	--[[
		Schedules a peculiar emission and requires emission to pass for full closure.
		Desynchronizes the emission from main thread.
	]]
	Observable.emit = function(self: any, item: any?)
		local function PassTroughFilter()
			return Promise.new(function(resolve: any, reject: any, onCancel: any)
				EMISSIONS(EMISSIONS:get() + 1)

				resolve(Observable._filter(item))
			end :: any) :: { read andThen: any }
		end

		PassTroughFilter():andThen(function(item)
			emission(item)

			EMISSIONS(EMISSIONS:get() - 1)
		end, function(err)
			warn(tostring(err))
		end)

		return Observable
	end

	--[[
		Binds a function to be called upon the closing of the observable.
	]]
	Observable.onclose = function(self: any, name: any)
		return function(fn: nil | (...any?) -> ...any?)
			_onclose[name or fn] = fn
			return Observable
		end
	end

	--[[
		Close the observable, end all connections and fire functions connected to the closure.
	]]
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

	Observable.__deleter = function()
		Observable:close()
	end

	--[[
		Shortcut to Observable:connect(fn)(fn)
	]]
	Observable.subscribe = function(self: any, fn: (...any?) -> ...any?)
		Observable:connect(fn)(fn)
		return Observable
	end

	--[[
		Shortcut to Observable:connect(fn)(nil)
	]]
	Observable.unsubscribe = function(self: any, fn: (...any?) -> ...any?)
		Observable:connect(fn)(nil)
		return Observable
	end

	----------------------------------------------
	-- Observable operators
	----------------------------------------------

	--[[
		Create a new observable that entirely depends and reemits each and all emissions from the original observable.
	]]
	local pipe = function(self: Types.Observable)
		local new: Types.Observable = ObservableConstructor(garbage)

		--new._filter = filter

		local fn: any = nil
		fn = function(t: any, ...)
			if not new or not new.emit then
				self:unsubscribe(fn)
				return
			end
			new:emit(...)
		end

		self:subscribe(fn)

		self:onclose {}(function()
			new:BindToLastEmission(function()
				new:close()
			end)
		end)

		return new
	end

	--[[
		Pipes a new observable that is connected to the Observables within merger
	]]
	Observable.merge = function(self: Types.Observable, merger: { Types.STATE })
		local new = pipe(self)

		for _, obs: Types.STATE in merger do
			new:connect()(obs)
		end

		return new
	end

	--[[
		Takes only the first `amount` items from the Observable.
		Binds the observable to full closure upon having all scheduled emissions pass.
	]]
	Observable.take = function(self: Types.Observable, amount: number)
		local new = pipe(self)

		new._filter = function(item)
			amount -= 1
			if amount <= 0 then
				new:BindToClose()
			end

			return item
		end

		return new
	end

	--[[
		Reemits the last emission that should've happened into a dead, closed observable as the last item.
	]]
	Observable.last = function(self: Types.Observable)
		local last_item = nil

		local new = pipe(self)

		new:onclose {}(function(...: any?): ...any?
			new._filter = function(item)
				return item
			end
			new:emit(last_item)
		end)

		new._filter = function(item)
			last_item = item

			return
		end

		return new
	end

	--[[
		Closes the observable if no emissions occur in the `time` period after the last emission.
	]]
	Observable.timeout = function(self: Types.Observable, time: number)
		local new = pipe(self)

		local begin = tick()

		new._filter = function(item)
			if tick() - begin >= time then
				new:close()
				return nil
			end
			begin = tick()

			return item
		end

		return new
	end

	--[[
		Delays each emission by `time` each.
	]]
	Observable.delay = function(self: Types.Observable, time: number)
		local new = pipe(self)

		new._filter = function(item)
			task.wait(time)

			return item
		end

		return new
	end

	--[[
		Applies a function to each emission.
	]]
	Observable.map = function(self: Types.Observable, fn: (self: Types.Observable, ...any?) -> ...any?)
		local new = pipe(self)

		new._filter = function(item)
			return fn(new, item)
		end

		return new
	end

	--[[
		Accumulates a value by applying a function to each emission.
	]]
	Observable.scan = function(self: Types.Observable, fn: (self: Types.Observable, item: any?, result: any) -> ...any?)
		local new = pipe(self)

		local res = nil

		new._filter = function(item)
			if item then
				res = fn(new, item, res)
				item = res
			end

			return item
		end

		return new
	end

	--[[
		Before actual emissions, forces the emission of the provided sequence of items.
	]]
	Observable.startWith = function(self: Types.Observable, ...: any)
		local new = pipe(self)

		local sequence = { ... }

		(function()
			--task.wait()

			return Promise.new(function(resolve, reject, onCancel)
				task.wait()
				for _, item in sequence do
					new:emit(item)
				end
			end :: any)
		end)()

		return new
	end

	--[[
		Applies a function to each emission, and declines the emission if the function returns `false`.
	]]
	Observable.filter = function(self: Types.Observable, fn: (self: Types.Observable, ...any?) -> boolean)
		local new = pipe(self)

		new._filter = function(item)
			if not fn(new, item) then
				return
			end

			return item
		end
		return new
	end

	--[[
		Declines emissions that have have already been in the past; no matter the order
	]]
	Observable.distinct = function(self: Types.Observable, fn: (...any?) -> boolean)
		local new = pipe(self)

		local existed = {}

		new._filter = function(item): any
			if existed[item] then
				return
			end

			existed[item] = true

			return item
		end
		return new
	end

	--[[
		Declines emissions that are identical to the previous emission; removes duplicate items
	]]
	Observable.deduplicate = function(self: Types.Observable, fn: (...any?) -> boolean)
		local new = pipe(self)

		local previous: any? = nil

		new._filter = function(item): any
			if item == previous then
				return
			end

			previous = item

			return item
		end
		return new
	end

	--[[
		Emits `item` after `time` seconds. Does not interfere with other emissions
	]]
	Observable.timer = function(self: Types.Observable, time: number, item: any)
		local new = pipe(self);

		(function()
			return Promise.new(function(resolve, reject, onCancel)
				task.wait(time)
				resolve()
			end :: any) :: { read andThen: any }
		end)():andThen(function()
			new:emit(item)
		end)

		return new
	end

	--[[
		Declines the emission of first `amount` emissions
	]]
	Observable.skip = function(self: Types.Observable, amount: number)
		local new = pipe(self)

		new._filter = function(item): any
			amount -= 1

			if amount >= 0 then
				return
			end

			return item
		end

		return new
	end

	--[[
		Declines the emission of all elements.
	]]
	Observable.ignoreElements = function(self: Types.Observable)
		local new = pipe(self)

		new._filter = function(item): any
			return
		end

		return new
	end

	Observable = setmetatable(Observable, {
		__index = Observable.__customs,
		__call = last_apply(emission), --Observable.emit, --curry(Observable.emit, Observable),
	}) :: Types.Observable

	--Crossdirectory presets
	if Effect then
		local nmt = getmetatable(Observable) :: any

		-- preset effect extensions
		nmt.__concat = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) .. (with(value) :: any)
			end)
		end
		nmt.__unm = function(table)
			return Effect(garbage, function(with, _)
				return -with(table)
			end)
		end
		nmt.__add = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) + (with(value) :: any)
			end)
		end
		nmt.__sub = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) - (with(value) :: any)
			end)
		end
		nmt.__mul = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) * (with(value) :: any)
			end)
		end
		nmt.__div = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) / (with(value) :: any)
			end)
		end
		nmt.__idiv = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) // (with(value) :: any)
			end)
		end
		nmt.__mod = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) % (with(value) :: any)
			end)
		end
		nmt.__pow = function(table, value)
			return Effect(garbage, function(with, _)
				return (with(table) :: any) ^ (with(value) :: any)
			end)
		end

		nmt.__eq = function(table, value)
			return Effect(garbage, function(with, _): any
				return (with(table) :: any) == (with(value) :: any)
			end)
		end
		nmt.__lt = function(table, value)
			return Effect(garbage, function(with, _): any
				return (with(table) :: any) < (with(value) :: any)
			end)
		end
		nmt.__le = function(table, value)
			return Effect(garbage, function(with, _): any
				return (with(table) :: any) <= (with(value) :: any)
			end)
		end
	end

	return Observable
end

return ObservableConstructor

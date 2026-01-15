--!strict

local Types = require(script.Parent.Parent.Util.Types)

function curry(fn, x)
	return function(...)
		fn(x, ...)
	end
end

-- the basis is done, just figure out how queuing and ratelimiting is going to be done

return function<S>(t: S | Types.garbage, t0: S?): Types.Worker<S>
	--Garbage collector capability
	local Worker: Types.Worker<S> = t0 and t0 or t :: Types.Worker<S> or {} :: Types.Worker<S>

	-- // usables

	local THREAD: thread

	local function kill()
		if THREAD and coroutine.status(THREAD) ~= "dead" then
			coroutine.close(THREAD)
		end
	end

	local function respawn()
		THREAD = coroutine.create(function(...)
			while true do
				local cotask = coroutine.yield()
				if cotask then
					cotask()
				end
			end
		end)
		coroutine.resume(THREAD)

		Worker.thread = THREAD
	end
	respawn()

	-- // actual stuff

	Worker.respawn = function(_: any)
		kill()

		respawn()
	end

	Worker.__deleter = function()
		Worker = {} :: any
		Worker = nil :: any
		kill()
	end

	if t and (t :: any).__initial then
		table.insert(t, Worker.__deleter)
	end

	-- // useless stuff

	local function __nindex(_, k, v)
		if typeof(v) == "function" then
			--v = curry(v, Worker)
		end

		rawset(Worker, k, v)
	end

	--[[for k, v in t0 and t0 or t or {} do
		__nindex(nil, k, v)
	end]]

	--[[Worker = setmetatable(Worker :: any, {
		--__newindex = __nindex,
	}) :: Types.Worker<S>]]
	return Worker :: Types.Worker<S>

	--[[return setmetatable(Worker :: any, {
		--__newindex = __nindex,
	}) :: Types.Worker<S>]]
end :: Types.WorkerConstructor

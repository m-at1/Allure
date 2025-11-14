--!strict

local main = script.Parent.Parent
local Log = require(main.Log)
local Types = require(main.Types)

return (
	function(
		garbage: Types.garbage<any>,
		object: Instance,
		amplified: Types.Amplified<unknown>,
		fn: nil | (self: any, object: Instance) -> ...any,
		lifetime: nil | (self: any, object: Instance) -> ...any
	): any
		-- FORMAT:
		-- garbage:mount(frame, Amplify {
		--	something
		-- }, function(self, object)	-- self is the table
		--		...
		--		return {}	--return what should be exposed
		-- end, function(self, object)
		--		... -- lifetime asynchronous function here
		-- end
		-- ) 	--{}		-- dependencies? inner components that can be referred to (nevermind, use amplified table as dependencies since nonexistent props unassigned)

		local checkedformutability = {}

		local checkformutability = function(k, v)
			if checkedformutability[k] == false then
				return
			end
			local success = pcall(function()
				(object :: any)[k] = v
			end)
			--warn(success, val)
			checkedformutability[k] = success
		end

		local up = function(s)
			for k: unknown, v in s do
				checkformutability(k, v)
			end
		end

		--warn(lifetime)
		local asyncLifetime = lifetime and coroutine.create(function()
			lifetime(amplified, object)
		end) or nil
		if asyncLifetime then
			coroutine.resume(asyncLifetime)
		end

		table.insert(garbage, {
			__deleter = function()
				print("mounted object deletion")
				if asyncLifetime then
					coroutine.close(asyncLifetime)
				end
				object:Destroy()
				amplified:connect(up)(nil)
			end,
		})

		local _events = {} --[string]:

		local donevalue = {} --copy of __value except for the handled cases

		amplified:connect(up)(function(_, k, v)
			--warn(k, v)

			-- case 1: check for the previous value
			if typeof(donevalue[k]) == "Instance" and donevalue[k] ~= v then
				donevalue[k].Parent = nil
			end

			-- case 2: check for the new value
			if typeof(k) == "number" and typeof(v) == "Instance" then
				v.Parent = object
				donevalue[k] = v
			end

			if _events[k] then
				_events[k]:Disconnect()
				_events[k] = nil
			end

			-- case 4: onevent, onchange or amplified
			if typeof(v) == "table" then
				if v.__kind == "onevent" then
					local ok = pcall(function()
						-- object:: any silences instance dynamic reference errors
						_events[k] = (object :: any)[v.event]:Connect(function(...)
							v.fn(amplified, object, ...)
						end)
					end)

					if not ok then
						--print(err)
						Log.logError("onEventNone", v.event, object.Name)
					end
				elseif v.__kind == "onchange" then
					local ok = pcall(function()
						_events[k] = object:GetPropertyChangedSignal(v.prop):Connect(function(...)
							v.fn(amplified, object, ...)
						end)
					end)

					if not ok then
						--print(err)
						Log.logError("onChangeNone", v.prop, object.Name)
					end
				else
					up(v)
				end
			end

			-- case 3: check for normal props
			if typeof(k) ~= "number" then
				checkformutability(k, v)
			end

			return
		end)

		for k: unknown, v in amplified.__value :: any do
			--if typeof(v)=="table" then up(v) continue end
			--checkformutability(k, v)
			(amplified.connections[up] :: any)(amplified, k, v)
		end

		return if fn then fn(amplified, object) else object
	end :: any
) :: Types.mount

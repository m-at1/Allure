--!strict

local UTIL = script.Parent.Parent.Parent.Util
local Log = require(UTIL.Log)
local Types = require(UTIL.Types)

local Config = require(script.Parent.Parent.Parent.Config)
local deepmerge = require(UTIL.deepMerge)

type State<T> = Types.StateObject<T>

local function cleanItem(j: any, rec: number)
	if rec >= Config.garbage_recursion_limit then
		Log.logWarning("AllureRX", "trash_recursion")
		return
	end
	rec += 1

	--absolve of the @mt
	for k, i in ipairs(j) do
		if typeof(i) == "Instance" then
			i:Destroy()
		elseif typeof(i) == "RBXScriptConnection" then
			i:Disconnect()
		elseif typeof(i) == "function" then
			(i :: any)()
		end

		if typeof(i) == "table" then
			i = i :: {
				__deleter: (a: any) -> (),
			}
			if i.__deleter then
				i.__deleter(i)
			elseif i.deleter then
				i:deleter()
			elseif i.destroy then
				i.destroy(i)
			elseif i.Destroy then
				i.Destroy(i)
			elseif i._destroy then
				i._destroy(i)
			elseif i._Destroy then
				i._Destroy(i)
			end
		end

		if typeof(i) == "table" then
			cleanItem(i, rec)
		end
		j[k] = nil
	end
end

function constructor(gc: any?, ...: any): any
	local temp = deepmerge(... or {}, (gc and gc.__initial or (gc and gc or {})))

	local grb: { Types.trashable } = {} :: { Types.trashable }

	if gc and gc.__initial then
		table.insert(gc :: { any }, grb)
	end

	temp.__initial = temp

	local garbage = setmetatable(grb, {
		__call = function()
			cleanItem(grb, 0)
		end,
		__index = temp,
	}) :: any

	return garbage
end

return (constructor :: any) :: Types.garbageConstructor

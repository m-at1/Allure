--!strict

local Config = require "@self/Config"

local UTIL = require(script.Util)
local Types = require(script.Util.Types)

export type State<T = any> = Types.StateObject<T>
export type garbage = Types.garbage
export type Amplified<T> = Types.Amplified<T>
export type Observable = Types.Observable

type function extend(ty: type, _INCLUDE: type, AlloyRX: type, AlloyBundle: type)
	--return _INCLUDE

	for singleton: string, type: type in pairs {
		AlloyRX = AlloyRX,
		AlloyBundle = AlloyBundle,
	} do
		if _INCLUDE:readproperty(types.singleton(singleton :: string)) then
			ty = types.intersectionof(ty, type :: type)
		end
	end

	--[[
	if _INCLUDE:readproperty(types.singleton "AlloyRX") then
		ty = types.intersectionof(ty, AlloyRX)
	end
	]]

	return ty
end

local Alloy = table.freeze(UTIL.extend({
	_version = { major = 0, minor = 1, patch = 0, isRelease = false },
}, Config._INCLUDE)) :: extend<Types.Alloy, typeof(Config._INCLUDE), Types.AlloyRX, Types.AlloyBundle>

return Alloy

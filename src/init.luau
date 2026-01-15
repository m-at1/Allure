--!strict

local UTIL = require(script.Util)
local Types = require(script.Util.Types)

export type State<T = any> = Types.StateObject<T>
export type garbage = Types.garbage
export type Amplified<T = any & {}> = Types.Amplified<T>
export type Observable = Types.Observable
export type Worker<T = any & {}> = Types.Worker<T>

type function extend(ty: type, _INCLUDE: type, AllureRx: type, AllureBundle: type)
	--return _INCLUDE

	for singleton: string, type: type in
		pairs {
			AllureRx = AllureRx,
			AllureBundle = AllureBundle,
		} :: any
	do
		if _INCLUDE:readproperty(types.singleton(singleton :: string)) then
			ty = types.intersectionof(ty, type :: type)
		end
	end

	--[[
	if _INCLUDE:readproperty(types.singleton "AllureRX") then
		ty = types.intersectionof(ty, AllureRX)
	end
	]]

	return ty
end

local Allure =
	table.freeze(UTIL.extend({ _version = { major = 0, minor = 1, patch = 0, isRelease = false } } :: Types.Allure, {
		"AllureRx",
		"AllureUI",
		"AllureBundle",
		Worker = "AllureWorker",
	}) :: {}) :: Types.Allure --:: extend<Types.Allure, typeof(Config._INCLUDE), Types.AllureRX, Types.AllureBundle>

return Allure

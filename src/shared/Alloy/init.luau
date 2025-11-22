--!strict

local SharedHandler = require "@self/Boundary/SharedHandler"
local Types = require(script.Types)

export type State<T = any> = Types.StateObject<T>
export type garbage = Types.garbage
export type Amplified<T> = Types.Amplified<T>

local garbage = require(script.State.Garbage)
--local derive = require(script.State.derive)

local State = require(script.State.State)
local get = require(script.State.get)
local set = require(script.State.set)

local Amplify = require(script.Amplified.Amplified)
local onSet = require(script.Amplified.onSet)
local onEvent = require(script.Amplified.onEvent)
local onChange = require(script.Amplified.onChange)

local mount = require(script.Amplified.mount)

local SharedAmplified = require(script.Boundary.SharedHandler)

local Computed = require(script.presetExtensions.Computed)
local Effect = require(script.presetExtensions.Effect)
local Observer = require(script.presetExtensions.Observer)
local New = require(script.presetExtensions.New)

local Alloy = table.freeze {
	_version = { major = 0, minor = 1, isRelease = false },

	--State manager
	garbage = garbage :: Types.garbageConstructor,
	--derive = derive,

	State = State :: Types.StateConstructor,
	get = get :: (State<unknown>) -> any?,
	set = set :: (State<unknown>) -> any?,

	Amplify = Amplify :: Types.AmplifiedConstructor,
	onSet = onSet :: Types.onSet,
	onEvent = onEvent :: Types.onEvent,
	onChange = onChange,

	mount = mount :: Types.mount,

	Shared = SharedHandler,

	Computed = Computed,
	Effect = Effect,
	Observer = Observer,
	New = New,
} :: Types.Alloy

return Alloy

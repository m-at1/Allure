--!strict

local Types = require(script.Parent.Util.Types)

type State<T = any> = Types.StateObject<T>
type garbage = Types.garbage
type Amplified<T> = Types.Amplified<T>

return {
	garbage = require(script.State.Garbage) :: Types.garbageConstructor,

	State = require(script.State.State) :: Types.StateConstructor,
	get = require(script.State.get) :: (State<unknown>) -> any?,
	set = require(script.State.set) :: (State<unknown>) -> any?,

	Amplify = require(script.Amplified.Amplified) :: Types.AmplifiedConstructor,
	onSet = require(script.Amplified.onSet) :: Types.onSet,
	onEvent = require(script.Amplified.onEvent) :: Types.onEvent,
	onChange = require(script.Amplified.onChange),

	mount = require(script.Amplified.mount) :: Types.mount,
}

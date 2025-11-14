--!strict

--stylua: ignore start

--[[ @section util ]]
export type Callable = (...any?) -> (...any?) | typeof(setmetatable({}, {} :: {__call: (...any?) -> (...any?)}))

export type SpecialValue<K, P> = {["__kind"]: K} & P
--[[ @end_section util ]]

--[[ @section State ]]

--[=[
	Inner state block representation inhabiting __value, setter getter deleter updater custom and connect
]=]
export type State<T, V={}> = {
	__getter: () -> any?,
	__setter: (...any?) -> any?,
	__updater: ({[any]: nil | (any?)->any?}?) -> nil,
	__deleter: () -> nil,
	
	__value: T?,
	get: (self:State<T, V>) -> any?,
	
	__customs: {[string]: any?},
	connections: {[any]: nil | (any?)->any?},
	
	getter:  ( self: State<T, V>, (self: State<T, V>) -> any? ) -> State<T, V>,
	setter:  <E>( self: State<T, V>, nil | (self: State<T, V>, ...E) -> ...any?) -> State<T, V>,
	
	updater: (self: State<T, V>, fn: nil | (self: State<T, V>, fn2: nil | (any?)->any ) -> any?) -> State<T, V>,
	deleter: (self: State<T, V>, (self: State<T, V>) -> any?) -> State<T, V>,
	custom:  (self: State<T, V>, name: string) -> (fn: any?)->State<T, V>,
	connect: (self: State<T, V>, name: any?) -> (fn:nil | (any?)->any?)->State<T, V>
} & V

--[=[
	State value that can be subscribed to
]=]
export type StateObject<T, V={}> = (typeof(
	setmetatable({} :: State<T>, {__index = function() end})
	) & V --& State<T>
)

export type StateConstructor = (garbage<unknown>, unknown)->(StateObject<unknown>)

--[=[
	Contents of a garbage collector
]=]
export type trashable = 
	Instance |
	()->() |
	State<any?> |
	RBXScriptConnection |
	{__deleter: ()->()} |
	{Destroy: ()->()} |
	{destroy: ()->()} |
	{_destroy: ()->()} |
	{_Destroy: ()->()}

export type garbage<T={}> = typeof(setmetatable( {} :: {trashable}, {} :: {__call: ()->()}) ) & T

--[=[
	Garbage collector out of (up to) 11 combined component tables
]=]
export type garbageConstructor =
	& (() -> garbage & {})
	& (<S>(garbage & S) -> garbage & S)
	& (<T, S>(garbage & S, T & {}) -> garbage & S & T)
	& (<T, V, S>(garbage & S, T & {}, V & {}) -> garbage & S & T & V)
	& (<T, V, E, S>(garbage & S, T & {}, V & {}, E & {}) -> garbage & S & T & V & E)
	& (<T, V, E, D, S>(garbage & S, T & {}, V & {}, E & {}, D & {}) -> garbage & S & T & V & E & D)
	& (<T, V, E, D, F, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}) -> garbage & S & T & V & E & D & F)
	& (<T, V, E, D, F, A, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}) -> garbage & S & T & V & E & D & F & A)
	& (<T, V, E, D, F, A, B, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}) -> garbage & S & T & V & E & D & F & A & B)
	& (<T, V, E, D, F, A, B, C, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}) -> garbage & S & T & V & E & D & F & A & B & C)
	& (<T, V, E, D, F, A, B, C, I, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}) -> garbage & S & T & V & E & D & F & A & B & C & I)
	& (<T, V, E, D, F, A, B, C, I, J, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}) -> garbage & S & T & V & E & D & F & A & B & C & I & J)
	& (<T, V, E, D, F, A, B, C, I, J, K, S>(garbage & S, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}, K & {}) -> garbage & S & T & V & E & D & F & A & B & C & I & J & K)

	& ((Alloy) -> garbage & Alloy)
	& (<S>(garbage & S, Alloy) -> garbage & S & Alloy)
	& (<T, S>(garbage & S, Alloy, T & {}) -> garbage & S & Alloy & T)
	& (<T, V, S>(garbage & S, Alloy, T & {}, V & {}) -> garbage & S & Alloy & T & V)
	& (<T, V, E, S>(garbage & S, Alloy, T & {}, V & {}, E & {}) -> garbage & S & Alloy & T & V & E)
	& (<T, V, E, D, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}) -> garbage & S & Alloy & T & V & E & D)
	& (<T, V, E, D, F, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}) -> garbage & S & Alloy & T & V & E & D & F)
	& (<T, V, E, D, F, A, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}) -> garbage & S & Alloy & T & V & E & D & F & A)
	& (<T, V, E, D, F, A, B, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}) -> garbage & S & Alloy & T & V & E & D & F & A & B)
	& (<T, V, E, D, F, A, B, C, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}) -> garbage & S & Alloy & T & V & E & D & F & A & B & C)
	& (<T, V, E, D, F, A, B, C, I, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}) -> garbage & S & Alloy & T & V & E & D & F & A & B & C & I)
	& (<T, V, E, D, F, A, B, C, I, J, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}) -> garbage & S & Alloy & T & V & E & D & F & A & B & C & I & J)
	& (<T, V, E, D, F, A, B, C, I, J, K, S>(garbage & S, Alloy, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}, K & {}) -> garbage & S & Alloy & T & V & E & D & F & A & B & C & I & J & K)

	& (<T>(T & {}) -> garbage & T)
	& (<T, V>(T & {}, V & {}) -> garbage & T & V)
	& (<T, V, E>(T & {}, V & {}, E & {}) -> garbage & T & V & E)
	& (<T, V, E, D>(T & {}, V & {}, E & {}, D & {}) -> garbage & T & V & E & D)
	& (<T, V, E, D, F>(T & {}, V & {}, E & {}, D & {}, F & {}) -> garbage & T & V & E & D & F)
	& (<T, V, E, D, F, A>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}) -> garbage & T & V & E & D & F & A)
	& (<T, V, E, D, F, A, B>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}) -> garbage & T & V & E & D & F & A & B)
	& (<T, V, E, D, F, A, B, C>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}) -> garbage & T & V & E & D & F & A & B & C)
	& (<T, V, E, D, F, A, B, C, I>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}) -> garbage & T & V & E & D & F & A & B & C & I)
	& (<T, V, E, D, F, A, B, C, I, J>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}) -> garbage & T & V & E & D & F & A & B & C & I & J)
	& (<T, V, E, D, F, A, B, C, I, J, K>(T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}, K & {}) -> garbage & T & V & E & D & F & A & B & C & I & J & K)
--[[ @end_section State ]]

--[[ @section Amplified Tables ]]

--[=[
	Inner & outer table state block
]=]
export type Amplified<T, V={}> = typeof(
	setmetatable( {} :: { --}, {} :: {})--__index: (...any?)->(...any?), __newindex: (...any?)->(...any?)} )
--) & {
	__getter: () -> any?,
	__setter: (...any?) -> any?,
	__updater: (...any?)->any,
	__deleter: () -> nil,
	
	__events: {[string]: (...any)->...any?},
	__enumerated: {},
	__children: {},
	
	_updaters: {[string]: (...any) -> (...any?) },
	_states: {[string]: StateObject<unknown>},
	_onsets: {[string]: {[any]: (any)->()} },

	__value: T & {},
	get: (self: Amplified<T, V>) -> any?,

	__customs: {[string]: any?},
	connections: {[any]: nil | (...any?)->any?},

	getter:  ( self: Amplified<T, V>, (self: Amplified<T, V>) -> any? ) -> Amplified<T, V>,
	setter:  <E>( self: Amplified<T, V>, nil | (self: Amplified<T, V>, ...E) -> ...any?) -> Amplified<T, V>,

	updater: (self: Amplified<T, V>, fn: nil | (self: Amplified<T, V>, fn2: nil | (any?)->any ) -> any?) -> Amplified<T, V>,
	deleter: (self: Amplified<T, V>, (self: Amplified<T, V>) -> any?) -> Amplified<T, V>,
	custom:  (self: Amplified<T, V>, name: string) -> (fn: any?)->Amplified<T, V>,
	connect: (self: Amplified<T, V>, name: any?) -> (fn:nil | (...any?)->any?)->Amplified<T, V>
} --& V
, {} :: {})
) & V

export type AmplifiedConstructor = (garbage<unknown>, unknown)->(Amplified<unknown>)

--[=[
	Amplified Specialvalues
]=]
export type onSet = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onset", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onset"]: string}>
export type onChange = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onchange", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onchange"]: string}>
export type onEvent = (event: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onevent", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["event"]: string}>

export type Lifetime = (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"lifetime", {["fn"]: (self: Amplified<unknown>)->...any?}>

export type mount = <T>(garbage: garbage<any>, object: Instance, amplified: Amplified<unknown>, fn: nil | (self: any, object: Instance)->...any, lifetime: nil | (self: any, object: Instance)->...any)->T

--[[ @end_section Amplified Tables ]]


export type Alloy = {
	_version: {major: number, minor: number, isRelease: boolean},
	
	garbage: garbageConstructor,

	State: StateConstructor,
	get: (State<unknown>)->any?,
	set: (State<unknown>, ...any?)->any?,
	
	--Amplify: AmplifiedConstructor,
	onSet: onSet,
	onEvent: onEvent,
	onChange: onChange,
	
	mount: mount,
	
	Computed: (trash: garbage<Alloy & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,
	Effect: (trash: garbage<Alloy & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,
	Observer: (trash: garbage<unknown>)->{_destroy: ()->(), onBind: ((...any?)->())->()->(), onChange: ((...any?)->())->()->()},
	New: (trash: garbage<unknown>, object: string) -> (propTable: {[number | string]: any} | Amplified<unknown>) -> Instance
}

return nil

--stylua: ignore end

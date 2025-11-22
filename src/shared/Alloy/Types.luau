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
export type StateConstructor = (garbage: garbage<unknown>, value: unknown)->(StateObject<unknown>)

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

export type AmplifiedConstructor = (garbage: garbage<unknown>, table: unknown)->(Amplified<unknown>)

export type onSet = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onset", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onset"]: string}>
export type onChange = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onchange", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onchange"]: string}>
export type onEvent = (event: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onevent", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["event"]: string}>

export type Lifetime = (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"lifetime", {["fn"]: (self: Amplified<unknown>)->...any?}>

export type mount = <T>(garbage: garbage<any>, object: Instance, amplified: Amplified<unknown>, fn: nil | (self: any, object: Instance)->...any, lifetime: nil | (self: any, object: Instance)->...any)->T


export type SchemaTypes = {
	
}

export type SharedAmplified = {
	All: (SharedAmplified, values: {[string | number]: any?} ) -> SharedAmplified,  
	For: (SharedAmplified, players: {Player}, values: {[string | number]: any?} ) -> SharedAmplified,
	getFor: (SharedAmplified, player: Player) -> ...any?,

	__replications: {[Player]: Amplified<unknown, unknown> }
} & Amplified<unknown, unknown>

--[[ @end_section Amplified Tables ]]


export type Alloy = {
	_version: {major: number, minor: number, isRelease: boolean},
	
	--[=[
		Creates a garbage collector with methods from the parameters.

		@param ...	*`string: function` tables.*

		@return `object` or `fn(amplified, object)`
	]=]
	garbage: garbageConstructor,

	--[=[
		State constructor.

		@param garbage    *Garbage Collector*
		@param value    *Initial value*
		@within Alloy

		@return StateObject
	]=]
	State: StateConstructor,

	--[=[
		Returns the actual value of a StateObject, avoids the getter method.

		@param state    *StateObject*

		@return The actual value
	]=]
	get: (state: State<unknown>)->any?,

	--[=[
		Sets the actual value of a StateObject, avoids the getter and setter methods.

		@param state    *StateObject*

		@return The new actual value.
	]=]
	set: (state: State<unknown>, ...any?)->any?,
	
	--[=[
		Creates an Amplified table.

		@param garbage    *Garbage Collector*
		@param table	*The table to convert into an Amplified*

		@return The amplified table.
	]=]
	Amplify: AmplifiedConstructor,

	--[=[
		Returns an event for use in Amplified tables.

		Fires whenever `prop` within the Amplified is set a new value.

		**Does not track indirect changes like `object.prop = value`**

		@param prop  *The property to track for changes*
		@param table  *The table to convert into an Amplified*

		@return A function that requires a callback with the parameters: Amplified Table, object.
	]=]
	onSet: onSet,

	--[=[
		Returns an `event` event for use in Amplified tables.

		This will only work on mounted Amplified tables.

		@param event  *The event*
		@param table  *The table to convert into an Amplified*

		@return A function that requires a callback with the parameters: Amplified Table, object, args passed by the event.
	]=]
	onEvent: onEvent,

	--[=[
		Returns an `GetPropertyChangedSignal` event on `prop` for use in Amplified tables.

		This will only work on mounted Amplified tables.

		@param prop  *The property to track for all changes*
		@param table  *The table to convert into an Amplified*

		@return A function that requires a callback with the parameters: Amplified Table, object, new value.
	]=]
	onChange: onChange,
	
	--[=[
		Mounts an Amplified table on an `instance`.

		@param garbage  *Garbage Collector*
		@param object  *The object to mount the Amplified on*
		@param amplified *The Amplified table*
		@param fn *Optional function that decides what the mounting will return*
		@param lifetime *Optional function that will be called and halted when the mounted object is cleaned*

		@return `object` or `fn(amplified, object)`
	]=]
	mount: mount,
	
	--[=[
		Mounts an Amplified table on an `instance`.

		@param garbage  *Garbage Collector*
		@param object  *The object to mount the Amplified on*
		@param amplified *The Amplified table*
		@param fn *Optional function that decides what the mounting will return*
		@param lifetime *Optional function that will be called and halted when the mounted object is cleaned*

		@return `object` or `fn(amplified, object)`
	]=]
	Shared: (tbl: {})->(),

	--[=[
		Preset extension Computed.
	]=]
	Computed: (trash: garbage<Alloy & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,

	--[=[
		Preset extension Effect.
	]=]
	Effect: (trash: garbage<Alloy & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,

	--[=[
		Preset extension Observer.
	]=]
	Observer: (trash: garbage<unknown>)->{_destroy: ()->(), onBind: ((...any?)->())->()->(), onChange: ((...any?)->())->()->()},

	--[=[
		Preset extension New.

		@param garbage	*Garbage Collector*
		@param object	*The object to create, string*

		@return Instance
	]=]
	New: (trash: garbage<unknown>, object: string) -> (propTable: {[number | string]: any} | Amplified<unknown>) -> Instance
}

return nil

--stylua: ignore end

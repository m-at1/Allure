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
	__getter: () -> T,
	__setter: (T) -> ...any,

	__updater: ( 
		{[any]: (any) -> ...any?}
	) -> (),

	__deleter: () -> (),
	
	__value: T,
	get: (self:State<T, V>) -> T,
	
	__customs: {[string]: any?},
	connections: {[any]: (any) -> ...any?},
	
	getter:  (
		self: State<T, V>, (self: State<T, V>) -> T 
	) -> State<T, V>,

	setter:  ( 
		self: State<T, V>, 
		nil | (self: State<T, V>, T) -> ...any?
	) -> State<T, V>,
	
	updater: (
		self: State<T, V>, 
		(self: State<T, V>, fn2: (any) -> ...any? ) -> any?
	) -> State<T, V>,

	deleter: (
		self: State<T, V>, 
		(self: State<T, V>) -> any?
	) -> State<T, V>,

	custom:  (
		self: State<T, V>, name: string
	) -> ( any? ) -> State<T, V>,

	connect: (
		self: State<T, V>, name: any?
	) -> ( nil | (...any?)->() | any? ) -> State<T, V>
} & V

--[=[
	State value that can be subscribed to
]=]
export type StateObject<T, V={}> = setmetatable<State<T>, {__index: () -> (), __call: (...any)->...any?}> & V --& State<T>

export type StateConstructor = (garbage: garbage<unknown>, value: unknown)->(StateObject<unknown>)

--[=[
	Contents of a garbage collector
]=]
export type trashable = 
	Instance |
	()->() |
	State<any?> |
	StateObject<any?> |
	RBXScriptConnection |
	{__deleter: ()->()} |
	{Destroy: ()->()} |
	{destroy: ()->()} |
	{_destroy: ()->()} |
	{_Destroy: ()->()}

export type garbage<T={}> = setmetatable<{trashable}, {__call: ()->()}> & T


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

	& ((Allure) -> garbage & Allure)
	& (<S>(garbage & S, Allure) -> garbage & S & Allure)
	& (<T, S>(garbage & S, Allure, T & {}) -> garbage & S & Allure & T)
	& (<T, V, S>(garbage & S, Allure, T & {}, V & {}) -> garbage & S & Allure & T & V)
	& (<T, V, E, S>(garbage & S, Allure, T & {}, V & {}, E & {}) -> garbage & S & Allure & T & V & E)
	& (<T, V, E, D, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}) -> garbage & S & Allure & T & V & E & D)
	& (<T, V, E, D, F, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}) -> garbage & S & Allure & T & V & E & D & F)
	& (<T, V, E, D, F, A, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}) -> garbage & S & Allure & T & V & E & D & F & A)
	& (<T, V, E, D, F, A, B, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}) -> garbage & S & Allure & T & V & E & D & F & A & B)
	& (<T, V, E, D, F, A, B, C, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}) -> garbage & S & Allure & T & V & E & D & F & A & B & C)
	& (<T, V, E, D, F, A, B, C, I, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}) -> garbage & S & Allure & T & V & E & D & F & A & B & C & I)
	& (<T, V, E, D, F, A, B, C, I, J, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}) -> garbage & S & Allure & T & V & E & D & F & A & B & C & I & J)
	& (<T, V, E, D, F, A, B, C, I, J, K, S>(garbage & S, Allure, T & {}, V & {}, E & {}, D & {}, F & {}, A & {}, B & {}, C & {}, I & {}, J & {}, K & {}) -> garbage & S & Allure & T & V & E & D & F & A & B & C & I & J & K)

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

export type _AMP<T, V={}> = { --}, {} :: {})--__index: (...any?)->(...any?), __newindex: (...any?)->(...any?)} )
	__getter: () -> T,
	__setter: (T) -> ...any,

	__updater: (
		a: { 
			[any]: (self: Amplified<T, V>, k: any, v: any) -> ...any? 
		}, 
		any, 
		any
	) -> any,

	__deleter: () -> (),
	
	--TODO
	__events: {[string]: (...any)->...any?},
	
	_updaters: {[string]: (...any) -> (...any?) },
	_states: {[string]: StateObject<unknown>},
	_onsets: {[string]: {[any]: (any)->()} },

	__value: T & {},

	get: (self: Amplified<T, V>) -> T,
	
	__customs: {[any]: any?},
	connections: { 
		[any]: (self: Amplified<T, V>, k: any, v: any) -> ...any? 
	},
	
	getter:  (
		self: Amplified<T, V>, (self: Amplified<T, V>) -> T 
	) ->Amplified<T, V>,

	setter:  ( 
		self: Amplified<T, V>, 
		nil | (self: Amplified<T, V>, T) -> ...any?
	) -> Amplified<T, V>,
	
	updater: (
		self: Amplified<T, V>, 
		(self: Amplified<T, V>, fn2: (any) -> ...any? ) -> any?
	) -> Amplified<T, V>,

	deleter: (
		self: Amplified<T, V>, 
		(self: Amplified<T, V>) -> any?
	) -> Amplified<T, V>,

	custom:  (
		self: Amplified<T, V>, name: string
	) -> ( any? ) -> Amplified<T, V>,

	connect: (
		self: Amplified<T, V>, name: any?
	) -> ( nil | (self: Amplified<T, V>, k: any, v: any)->any? ) -> Amplified<T, V>
} & V

export type Amplified<T, V={}> = setmetatable<_AMP<T, V>, {__index: () -> (), __call: (...any)->...any?}>

export type AmplifiedConstructor = (garbage: garbage<unknown>, table: unknown)->(Amplified<unknown>)

export type onSet = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onset", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onset"]: string}>
export type onChange = (prop: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onchange", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["onchange"]: string}>
export type onEvent = (event: string) -> (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"onevent", {["fn"]: (self: Amplified<unknown>, object: Instance, ...any?)->...any?} & {["event"]: string}>

export type Lifetime = (fn: (self: Amplified<unknown>)->...any?) -> SpecialValue<"lifetime", {["fn"]: (self: Amplified<unknown>)->...any?}>

export type mount = <T>(garbage: garbage<any>, object: Instance, amplified: Amplified<unknown>, fn: nil | (self: any, object: Instance)->...any, lifetime: nil | (self: any, object: Instance)->...any)->T

export type SharedAmplified = {
	All: (SharedAmplified, values: {[string | number]: any?} ) -> SharedAmplified,  
	For: (SharedAmplified, players: {Player}, values: {[string | number]: any?} ) -> SharedAmplified,
	getFor: (SharedAmplified, player: Player) -> ...any?,

	__replications: {[Player]: Amplified<unknown, unknown> }
} & Amplified<unknown, unknown>

--[[ @end_section Amplified Tables ]]

--[[ @section Observables ]]

export type Observable = setmetatable<{
	connections: { 
		[any]: (...any?) -> ...any? 
	},
	_filter: (any?)->any?,

	connect: (
		self: any,
		name: any?
	) -> ( nil | (...any?) -> ...any? ) -> Observable,

	emit: (
		self: any,
		...any?
	) -> Observable,

	onclose: (self: Observable, name: any) -> (fn: nil | (...any?) -> ...any?) -> Observable,
	close: (self: any) -> (),
	
	BindToClose: (self: any) -> Observable,
	BindToLastEmission: (self: any, fn: ()->()) -> Observable,

	subscribe: (
		self: any,
		fn: (...any?)->...any?
	) -> Observable,
	unsubscribe: (
		self: any,
		fn: (...any?)->...any?
	) -> Observable
} & {
	---list of observable operators
	pipe: (Observable) -> Observable,

	--transformation
	take: (Observable, amount: number) -> Observable,
	last: (Observable) -> Observable,

	filter: (Observable, fn: (...any) -> boolean) -> Observable,
	timeout: (Observable, time: number) -> Observable,

	delay: (Observable, time: number) -> Observable,
	startWith: (Observable, ...any) -> Observable,

	map: (Observable, fn: (...any)->...any) -> Observable,
	scan: (Observable, fn: (item: any?, result: any?)->...any) -> Observable,

	distinct: (Observable) -> Observable,
	deduplicate: (Observable) -> Observable,

	timer: (Observable, time: number, item: any) -> Observable,
	--Range
	--Interval

	skip: (Observable, amount: number) -> Observable,
	ignoreElements: (Observable) -> Observable,
}, {
	__call: (
		...any?
	) -> Observable,
}>

--[[ @end_section Amplified Tables ]]

export type Allure = {
	--_extend: any?,
	_version: {major: number, minor: number, isRelease: boolean},
}

export type AllureRX = {
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
		@within Allure

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
		Creates an empty observable stream. Identical to Never
	]=]
	Observable: (garbage: garbage<any>)->Observable,

	--[=[
		Creates an observable stream that does not emit anything and closes immediately.
	]=]
	Empty: (garbage: garbage<any>)->Observable,

	--[=[
		Creates an observable stream that emits `item` and closes immediately.
	]=]
	Just: (garbage: garbage<any>, item: any)->Observable,

	--[=[
		Creates an observable stream that emits integers starting from n and ending at m. 
		</br>Ascends each emission by 1 if m > n and -1 if m < n.
		</br>Immediately closes the observable afterwards.
	]=]
	Range: (garbage: garbage<any>, n: number, m: number)->Observable,

	--[=[
		Creates an observable that repeats a sequence of items `amount` times and closes.
	]=]
	Repeat: (garbage: garbage<any>, amount: number, ...any)->Observable,

	--[=[
		Creates an observable stream that emits ascending integers starting from 0 infinitely, spaced by `interval` ms each.
	]=]
	Interval: (garbage: garbage<any>, interval: number)->Observable,

	--[=[
		unfinished
	]=]
	Shared: (tbl: {})->(),

}

export type AllureBundle = {
	--[=[
		Preset extension Computed.
	]=]
	Computed: (trash: garbage<Allure & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,

	--[=[
		Preset extension Effect.
	]=]
	Effect: (trash: garbage<Allure & {} & any>, fn: (with: (...any)->(), innertrash: garbage) -> ()) -> StateObject<nil>,

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

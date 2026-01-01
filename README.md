<p align="center">
  <img width="500" height="250" src="https://github.com/m-at1/Alloy/blob/main/images/logo.png?raw=true" alt="Logo">
</p>

<p align="center">
  <b><i>Reactive Framework of Frameworks for the Roblox Metaverse.</i></b> </br>
  <i>Inspired by Spring</i>
</p>

<h1></h1>
</br>
<div align="center">
  <a href="https://github.com/m-at1/Alloy/releases"><img width="65" height="50" src="./images/Install.png" alt="Install"></a>‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="160" height="50" src="./images/Docs.png" alt="Docs"></a>ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="130" height="50" src="./images/Benchmarks.png" alt="Benchmarks"></a>
</div>
‎‎‎‎‎

# 🍀 *AllureRx*
- ## *<ins>Fantastic UI Framework</ins>: Amplified Tables*
  Amplified Tables extend the capabilities far further than any UI framework that there is.
### StyleSheets

> ```luau
> --[[ A table that will be used as a stylesheet ]]
> local frameDesign = {
>	  Parent = GUI,
>
>	  Size = UDim2.fromScale(0.6, 0.7),
>  	Position = UDim2.fromScale(0.5, 0.5),
>
>	  BackgroundColor3 = Color3.new(0.05098, 0.05098, 0.054902),
>	  BackgroundTransparency = 0.4,
>	  AnchorPoint = Vector2.new(0.5, 0.5),
>
>   --[[ Instances listed without a key are children ]]
>	  main:New "UIAspectRatioConstraint" {
>		    AspectRatio = 1.6,
>	  },
> }
>
> --[[ Creating a frame into the main garbage collector ]]
> local frame = main:New "Frame" {
>	  frameDesign,  -- Any table listed without a key is applied!
>
>	  main:New "TextButton" {
>		    frameDesign,
>
>         --[[
>             More tables, higher the order
>             Thus this second order table can overwrite the stylesheet
>         ]]
>		    { {  
>			      BackgroundTransparency = 0,
>	      } },
>	  },
> }
>```
- ## *<ins>Reactive Observables</ins>: Generating and filtering data streams*
  Generate, filter, subscribe to an observable from anywhere.
### Click Counter

> ```luau
> --[[ ...:New actually makes the table an amplified and mounts it! ]]
> main:New "TextButton" {
>     TextScaled = true,
>
>     --[[ You can use any key in Amplifieds ]]
>		_count = main:Observable(),
>
>     --[[
>         Whenever it is clicked, simply emit 1.
>         It will be accumulated and turned into a string that we need
>     ]]
>		Allure.onEvent "MouseButton1Click"(function(self: Allure.Amplified<any>)
>			self._count(1)
>		end),
>
>     --[[
>         Since we need _count to exist, to avoid race conditions,
>         use the next order by simply wrapping it in a table:
>     ]]
>		{
>			Text = function(self)  -- Amplifieds automatically call functions, we need this so we can reference _count
>				return self._count
>					:scan(function(self, value, total)  -- Accumulate the counting value with scan operator
>						return value + (total or 0)
>					end)                                -- And turn it into usable text with map operator
>					:map(function(self, item)
>						return "Count: " .. item
>					end)
>					:emit(0)    -- Emitting the starting value
>			end,
>		},
>},
>```
  This is not the best usage for observables, but a rather simple one. </br>
  Count the lines, because we're going to optimize it multiple times!
  
- ## *<ins>Customizable States</ins>: A low level core to everything*
  Customize the setter, getter, updater, deleter and create custom attributes. </br>
  States are interchangeable with observables or amplifieds, since they share all of these capabilities.
### I simplified the click counter
> ```luau
>main:New "TextButton" {
>
>     -- A state for the counter text
>		Text = main:State("Count: 0")
>			:custom "count"(0)  -- A custom attribute to have the current count
>			:setter(function(self, item)  -- And a custom setter to update the count, value and call connections (updater)
>				self.count = item
>				Allure.set(self, "Count: " .. item)
>  			self:updater()
>			end),
> 
>     -- Whenever it is clicked, set the state to the next number
>		Allure.onEvent "MouseButton1Click"(function(self)
>			self.Text(self.Text.count + 1)
>		end),
>},
>```

- ## *<ins>Simple Garbage Collection</ins>: Integrated into everything*
  For cleanup, simply call the garbage collector as a function. </br> After cleanup the garbage collector still can be used as fresh.
### GC
> ```luau
>main = Allure:garbage {insert = table.insert}
>
>main:insert(function()  -- Upon cleanup functions are called, instances are deleted, etc.
>    print("cleanup called!")
>end)
>
>main() -- cleanup called!
>```

# 🧱 *AllureBundle*
- ## *<ins>Stack and Spring</ins>: query and animate*
  Stacks and Springs are made given simple State customization. </br>You can easily make them yourself!
### Random Color
>```luau
>main:New "TextButton" {
>    BackgroundColor3 = main:Spring(Color3.new(1, 1, 1), 2, 0.8),
>
>    Allure.onEvent "MouseButton1Click"(function(self)
>        self.BackgroundColor3(Color3.new(   -- Spring is just a state with a heavily modified setter, so we simply call it with the goal value
>            math.random(1, 100) / 100,
>            math.random(1, 100) / 100,
>            math.random(1, 100) / 100
>        ))
>    end),
>}
>```

- ## *<ins>Effect, Computed, Observer</ins>: state needs*
  Inspired by Fusion, however, all of these are also made simply given state customization.
### I simplified the click counter again
>```luau
>main:New "TextButton" {
>    count = main:State(0),
>
>    Text = function(self)
>        return main:Effect(function(with, innergarbage)
>            return "Count: " .. with(self.count)
>        end)
>    end,
>
>    Allure.onEvent "MouseButton1Click"(function(self)
>        self.count(self.count:get() + 1)
>    end),
>},
>```

- ## *<ins>Effect Shortcuts</ins>: simpler, faster, easier*
  A lot of simple effects like `with(a) + b`, no matter if a is an observable, state or anything else, can be shortened to simply `a + b`.
### I simplified it even more
>```luau
>main:New "TextButton" {
>    count = main:State(0),
>
>    Text = function(self)
>        return "Count: " .. self.count
>    end,
>
>    Allure.onEvent "MouseButton1Click"(function(self)
>        self.count(self.count:get() + 1)
>    end),
>},
>```

# ⚡ *AllureNet*
- ## *<ins>State Synchronization</ins>: Shared Amplified Tables*
  ...
### ...

- ## *<ins>Guarded Observable Data Stream</ins>: Protocol*
  ...
### ...

.......

  - ***Heavily customizable composition of garbage collection, states and Observables***
    - Customize the setter, getter, updater, deleter of states, create custom attributes and more.
    - Seamlessly combine and react to observable streams and states.
      
  - ***UI Framework based on reactivity***
    - Use and customize heavily reactive amplified tables.
    - Mount amplified tables on instances.
- ### AllureBundle
  - ***Combination of preset extensions***
    - Such as Computed, Observer, Spring, Stack or Effect.
    - In Allure these are not builtin functionality: You can easily make one yourself.
      
  - ***A Guide to extending AllureRx***
    - Ability to create your own observable filters and operators with ease.
    - Clear guidance and shortcuts to creating reactive extensions.
- ### AllureNet
  - ***Give data to clients: Shared Amplified***
    - Acts as extended replicated state machinery.
    - Replicates each allowed key change to specific clients.
    - Can be exposed or hidden to specific clients.
      
  - ***Protocol: guarded data stream***
    - Represents a data stream between 2 ends, that can be anywhere on server or client, which is closely guarded by multiple tools.
    - Can be attached to anything: create a Protocol between clientside controllers, or a client-server protocol, or a protocol between serverside services, etc.
    - Has multiple tools required for guarding the data stream: memory limit, ratelimit, memory bytewise ratelimit, type guarding and many more.
- ### Aserde
  - ***The internal __schemaless__ serializer/deserializer***
    - Represent memory as metadata and data.
    - Requires no schema to read and write.
      
  - ***Optimized solution***
    - Is blazingly fast at reading and writing.
    - Performs deduplication.
## 🔮 What you can expect for 1.0.0
- ### AllureActor
  - ***Wrapper over roblox's Actor***
    - Written to provide more configuration.
    - Represent parallel luau in a professional way.
      
  - ***Reactivity: Microservice***
    - Independent parallel service.
    - Communicate only via Protocols and customizable rules, such as request-publish or request-reply.
- ### AllureDB
  - ***A serialized unit of data***
    - Make calls and requests to save, write, read.
    - Stores data in a secure location.
      
  - ***AQM: Allure Query Module***
    - Resembles SQL and SQLite.
    - Create cursors and navigate through databases with ease.
    - Apply filters and get fields you need.
- ### AllureMVC
  - ***Division of View and Logic units***
    - Componentize and make reusable logic.
    - Represent Model, View and Logic as microservices.
      
  - ***Central Controller***
    - Main Router Microservice that solves the problem for a multitude of clients at once.
    - Finish the idea with creating individual branches of controllers and microservices for each client.
    
## 🍏 Key Benefits
- ## Zero Pressure
  - Allure __doesn't enforce__ Actors or MVC. You can remove almost anything you need to avoid bloat. </br>
  You can use Allure only for states, or only for observables, or only for actors, or only for garbage collection. Because the rest can be easily removed without it all collapsing. </br>
  If you use AllureBundle only for extension, be it: remove the rest from AllureBundle.

- ## Heavily Extensible
  - AllureBundle purposes it so you can extend anyhow, anywhere you want! Create your own state machinery, extensions, streams, filters, microservices. </br>
  Then store these as a library or a package that you can carry along.

- ## Promotes good practices
  - If you use AllureRx you already use States and Garbage Collectors for sure. You obviously can use Allure with any other architecture, </br>
  but if you use AllureMVC, you're for sure already using Controllers. </br>
  Allure doesn't intend to hide complexity behind what it recommends you. You're not forced to customize states, for example, simply use Absolved States to avoid bloat.

---

> [!NOTE]
> ### *Alloy is a fresh project*
> Alloy has major plans for the upcoming features. </br>
> There are several instances of unfinished documentation, code, and issues.

# *In depth*
## ⚛️ AllureRx: GC, UI, States and Observables
-  AllureRx contains garbage collectors, states, observables, amplifieds and mounting.
  <br>Out of that:<br>

    * **States can be easily customized**
         > States have a setter, getter, updater, deleter, connections and can have custom attributes.
         > Never used customization? Use Absolved States, absolved of all the customization for performance.

    * **Amplified tables react to changes**
         > ***Amplified tables*** are a glorified `table` state with an entire multitude of additional customization alongside basic State features.
         > Amplifieds can be mounted on instances with lifetime functions, signals, specific updates, object pooling, etc.
           
    * **Representing communication and data with observable streams**
         > Observables are an extension of the standard State, implying that they have the exact same customization functionality.
         > Operators and filters generate new observables that can be subscribed to.

```luau
--[[ A Counter textbutton example ]]
--[[ Requires AllureRx + AllureBundle ]]

local function Counter(
  garbage: Allure.garbage,

  props
): Instance
  local count = garbage:State(0)

  return Allure.New "TextLabel" {
    Text = "Count: " .. count,

    mysignal = Allure.onEvent "MouseButton1Click" (function()
      count(count:get() + 1)
    end),

    props
  }
end
```
```luau
--[[ A Counter textbutton example with Observables ]]
--[[ Requires AllureRx + AllureBundle ]]

local function Counter(
  garbage: Allure.garbage,

  props
): Instance
  local count = garbage:Observable()
      :scan(function(value, total)
        return value + total
      end)
      :emit(0)

  return Allure.New "TextLabel" {
    Text = "Count: " .. count,

    mysignal = Allure.onEvent "MouseButton1Click" (function()
      count:emit(1)
    end),

    props
  }
end
```
---

## License
Allure is freely shared via MIT License.
Give me a shoutout if you want!

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

> [!NOTE]
> ### *Allure is a fresh project*
> Allure has major plans for the upcoming features. </br>
> There are several instances of unfinished documentation, code, and issues.‎‎‎‎‎

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


## 🔮 What you can expect for 1.0.0
- *AllureActor*
- *AllureDB*
- *AllureMVC*

---

## License
Allure is freely shared with the MIT License.
Give me a shoutout if you want!

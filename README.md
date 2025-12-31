<p align="center">
  <img width="500" height="250" src="https://github.com/m-at1/Alloy/blob/main/images/logo.png?raw=true" alt="Logo">
</p>

<p align="center">
  <i>Reactive Framework of Frameworks for the Roblox Metaverse.</i> </br>
  <i>Inspired by Spring</i>
</p>

<h1></h1>
</br>
<div align="center">
  <a href="https://github.com/m-at1/Alloy/releases"><img width="65" height="50" src="./images/Install.png" alt="Install"></a>‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="160" height="50" src="./images/Docs.png" alt="Docs"></a>ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="130" height="50" src="./images/Benchmarks.png" alt="Benchmarks"></a>
</div>

‎‎‎‎‎‎
## 🎨 Contains
- ### AllureRx
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

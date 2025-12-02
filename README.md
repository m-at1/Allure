<p align="center">
  <img width="500" height="250" src="https://github.com/m-at1/Alloy/blob/main/images/logo.png?raw=true" alt="Logo">
</p>

<p align="center">
  <i>Reactive Holistic Meta-framework for the Roblox Metaverse.</i>
</p>

<h1></h1>
</br>
<div align="center">
  <a href="https://github.com/m-at1/Alloy/releases"><img width="65" height="50" src="./images/Install.png" alt="Install"></a>‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="160" height="50" src="./images/Docs.png" alt="Docs"></a>ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="130" height="50" src="./images/Benchmarks.png" alt="Benchmarks"></a>
</div>
‎‎‎‎‎‎‎‎
<div align="center">

  ### Feature Matrix

| Feature / Paradigm / Architecture | *Alloy* | Fusion | Vide | Blend | React + Rodux/Charm | Knit + Comm |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| State Machinery (ISM) | ✅</br>Customizable | ✅</br>Main principle | ✅</br>Sources | ❌</br>Requires a tool | ✅</br>Rodux / Charm | ❌</br>Not purposed / Requires a tool |
| Garbage Collection | ✅</br>Forced / Integrated | ✅</br>Optional | ❌</br>Not present | ❌</br>Requires a tool | ❌</br>Requires a tool | ❌</br>Not purposed / Requires a tool |
| UI Framework | ✅</br>Present | ✅</br>Main purpose | ✅</br>Main purpose | ✅</br>Main purpose | ✅</br>React | ❌</br>Not purposed / Requires a tool |
| Replicated States | ✅</br>Shared Amplified | ❌</br>Not present | ❌</br>Not present | ❌</br>Requires a tool | ❌</br>Requires a tool | ✅</br>Charm | ❌</br>Not present |
| Network Middleware | ✅</br>Protocols | ❌</br>Not purposed / Requires a tool | ❌</br>Not purposed / Requires a tool | ❌</br>Requires a tool | ❌</br>Requires a tool | ✅</br>Charm | ❌</br>Not present |
| Architecture (MVC) | ✅</br>Forced / Integrated | ❌</br>User decision | ❌</br>User decision | ❌</br>User decision | ❌</br>User decision | ✅</br>Main purpose |
| Garbage Collection | A | F | v | B | R+R | K + C |
| Garbage Collection | A | F | v | B | R+R | K + C |

</div>

</br>

> [!NOTE]
> ### *Alloy is a fresh project*
> Alloy has major plans for the upcoming features. </br>
> There are several instances of unfinished documentation, code, and issues.

### Contents
- Architectural design patterns
- Introducing
- License

## 🍀 Architectural design patterns
- 🪟 ***Model-View-Controller***
  - Alloy induces a MVC pattern with Central Controller, Client Session Controllers and Model for the server; View Actor, Controller Actor(s) for the client.
    </br></br>
- 🎭 ***Actor-driven Reactivity***
  - Alloy refabricates Roblox's Actors into a much more controllable representation. Model and View utilize state machinery and communication is represented as a data stream.

# *Introducing*
## ⚛️ Reactive Programming: overly customizable state machinery and observables
-  Alloy introduces heavily extensible, customizable and replicated state machinery, observable streams and integrates everything into garbage collection.
  <br>Out of that:<br>

    * **States can be easily customized.**
         > States have a setter, getter, updater, deleter, connections and can pertain custom attributes in any shape or form.
         > ***Amplified tables*** are a glorified `table` state with entire multitude of additional customization alongside basic State features.
         > Amplifieds can be mounted on instances with lifetime functions, signals, specific updates, object pooling, etc.
           
    * **Representing I/O with observable streams**
         > Observables are an extension of the standard State, implying that they have the exact same customization functionality.
         > Operators generate new observables that can be subscribed to.
         > Subscribers track an observable and have a `unsubscribe`, `delete` and `resubscribe` functionality.

    * **Encouraging extension.**
         > Each of the mentioned benefits share one main goal: to **freely allow extension**. Create your own mounting, your own States, observables, operators, objects, pools and more. Suit the framework for your design and needs.

```luau
--[[ A Counter textbutton example ]]
local function Counter(
  garbage: Alloy.garbage,

  props
): Instance
  local count = garbage:State(0)

  return Alloy.New "TextLabel" {
    Text = "Count: " .. count,

    mysignal = Alloy.onEvent "MouseButton1Click" (function()
      count(count:get() + 1)
    end),

    props
  }
end
```

## 🎭 Model-View-Controller Architecture: via Actors
-  Alloy induces an MVC architecture approach with a custom refabrication of Actors: recreated for the better of control and opportunity.
   </br>The game's structure is then as follows:</br>

    * ### **Clientside**
        * ***View***
           > Uses a React-like approach with state machinery.
           
        * ***Controller***
           > The clientside controller is adapated to get input from View.
           > </br>The Controller Actor(s) generates an observable stream through the designated `protocol(s)`.

    * ### **Serverside**
        * ***Controller***
          * ***Central Controller***
             > Central Controller Actor gets traffic from the `protocols` used by clients.
             > </br>The traffic is routed and forwarded to the Client Session Controller created and designated to handle that client's session.
             > </br>The Central Controller can control the main game state and communicate with each client's session controllers.
   
          * ***Client Session Controllers***
             > Communicates with children Actors that handle their part of the client's game state. (Separation of Concerns)
             > </br>Sends traffic back to the clientside controller.
           
        * ***Model***
          * ***Logic***
             > All serverside logic separated into a single place.

          * ***Data***
             > The universal source of truth for player data and the game's state.

        * ***View (discouraged)***
          > Used for serverside rendering and loading of assets.


 - Anything out of this __can be customized.__
   </br> For example, you can divide clientside View into State, Model and Design. You can avoid the client session controllers if your game has less traffic. And much more.
   

## 〽️ Internal serializer
-  Aserde is the Alloy's internal buffer SerDes, optimized for multiple usecases:</br>

    * **Shared Amplified intends to give clients optimized state replication**, <br>
      > - so that clients can write their own getters and updaters for it. </br>
      > - Entire sections can be carried by Shared Amplified and mounted on the client's end, resulting in cheap SSR. </br>
      > - All replications serialize and replicate only the updating part.
    
    * **Rules act as specific permissions for a client to *act* and bring changes.** <br>
      > - Rules force and induce custom type guarding, ratelimits, query algorithms like Leaky Bucket and more. <br>
      > - All communication is serialized and the guards are double checked on both server and client aforehand.

```luau
--[[  ]]
local Alloy = require "../Packages/Alloy"

--...
```

## ...
  ...

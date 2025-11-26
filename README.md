<p align="center">
  <img width="500" height="250" src="https://github.com/m-at1/Alloy/blob/main/images/logo.png?raw=true" alt="Logo">
</p>

<p align="center">
  <i>Reactive Meta-framework for the Roblox Metaverse.</i>
</p>

<h1></h1>
</br>
<div align="center">
  <a href="https://github.com/m-at1/Alloy/releases"><img width="65" height="50" src="./images/Install.png" alt="Install"></a>‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="160" height="50" src="./images/Docs.png" alt="Docs"></a>ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ‎‎‎‎‎‎‎‎ㅤ
  <a href="https://github.com/m-at1/Alloy/releases"><img width="130" height="50" src="./images/Benchmarks.png" alt="Benchmarks"></a>
</div>
‎‎‎‎‎‎‎‎ㅤ
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
  - Alloy induces a MVC pattern with Model divided into Data & Logic and View as Design & State. Utilizing alloy to the full extent implies creating a game with Services, logic of which is separated into MVC.
    </br></br>
- 🎭 ***Actor-driven Reactivity***
  - Both frontend and backend are handled by microservices - *Actors*: Alloy's custom refabrication of Roblox's `Actor`s. 

# *Introducing*
## ⚛️ Reactive Programming: overly customizable React-like approach
-  Alloy introduces heavily extensible, customizable and replicated state machinery and integrates everything into garbage collection.
  <br>Out of that:<br>

    * **States can be easily customized.**
         > States have a setter, getter, updater, deleter, connections and can pertain custom attributes in any shape or form.
           
    * **Amplified table states track all key updates.**
         > Amplified tables are a glorified `table` state with entire multitude of additional customization alongside basic State features.
           
    * **Amplifieds can be mounted on instances.**
         > With lifetime functions, signals, specific updates, object pooling, etc.

    * **Encouraging extension.**
         > Each of the mentioned 3 benefits share one main goal: to **freely allow extension**. Create your own mounting, your own States, objects, pools and more. Suit the framework for your design and needs.

```luau
--[[ A Counter textlabel component example ]]
local Alloy = require "../Packages/Alloy"

return function(
  garbage: Alloy.garbage,
  count: Alloy.State<number>,
  
  props: Alloy.Amplified | {}

): Instance

  return Alloy.New "TextLabel" {
    Text = "Count: " .. count,

    props
  }
end
```
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

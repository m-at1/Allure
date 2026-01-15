# Installation
Allure itself is a framework that connects together frameworks. </br>
You don't have to `require` the frameworks individually: their functionality is merged with Allure.


## Roblox Studio directly
  Nothing new here:
>    1. Install the latest release directly
>    2. Place in the replicated storage


## Wally
  While individual frameworks aren't divided into packages, all of them are in this Allure package together
>    1. Add `Allure = ...` to your wally.toml
>    2. Call `wally init`


## Deleting frameworks
  You can freely delete frameworks, however there are some cases to remember:
>    - *AllureRx* and *AllureBundle* require AllureUI as they use states internally
>      
>    - *AllureWorker* does not require AllureUI but can be merged with garbage collection if you keep it.
>      
>    - *AllureUI* and *AllureRx* don't require AllureBundle but are modified if you keep it.

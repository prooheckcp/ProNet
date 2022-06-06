---
sidebar_position: 1
---

# Signal:fire 🟪

The :fire function fires all the event listeners on the other side of the connection. If called from the client it will fire all the events attached in the server. If called from the server it will fire all the events attached on the client side. Can take an infinite amount of arguments.

:fire calls wait for clients to load before sending the request meaning you can call the :fire as soon as the player joins the game.

**Parameters:**

| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|player    |``player?``| If :fire is called from the server the first argument should be the target client. If called from the client this argument is omitted.
|arguments |``Tuple`` | The arguments passed to the [ProNet.Event](#pronetevent) method |

**Returns:**

| Name     |Type      |Description                                                                                         |
|----------|----------|----------------------------------------------------------------------------------------------------|
|arguments |``Tuple`` | Will return void if the signal is of type Event, can return arguments in case the type is Function |

**Example:**

🟩Server:
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event,
    protected = false,
    requestLimit = 5,
    requestResetTime = 3
})

Players.PlayerAdded:Connect(function(player : Player)
    testSignal:fire(player, "Hello from the server!")
end)
```

🟦Client:
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")

testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage) --Output: Hello from the server!
end)
```
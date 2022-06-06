---
sidebar_position: 2
---

# ProNet.Signal:fireAll 🟪

The :fireAll function can be see as an extension of the :fire function. The main difference is that it fires all the clients instead of a single client when called from the server. This function cannot be called from the 🟦client!

**Parameters:**

| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|arguments |``Tuple`` | The arguments passed to the [Signal.Event](../dropdown-signal/event) method |

**Returns:**

| Name | Type | Description |
|------|--------|---------|
|      |``void``| |

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

task.wait(5)

testSignal:fireAll("Hello clients!")
```

🟦Client:
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")

testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage) --Output: Hello clients!
end)
```

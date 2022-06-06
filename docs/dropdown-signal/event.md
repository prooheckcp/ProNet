---
sidebar_position: 3
---

# Signal.Event ⚡

This is an event that can be attached to a signal on both the client and the server. It gets called whenever someone :fire's the signal associated to this signal.

**Parameters:**

| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|player |``Player?`` | If the event is attached in the client this argument won't exist. If attached in the server the first argument will represent the ``Player`` that fire the signal |
|arguments|``Tuple``| The arguments passed thru the network|

**Returns:**

| Name      | Type                 | Description |
|-----------|----------------------|---------|
|connection |[``ProNet.Connection``](#pronetconnection) | A connection that represents the event created. Allows you to disconnect the event at any point in the future|

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

local connection : ProNet.Connection = testSignal.Event:Connect(function(message : string)
    print(message) -- Won't output anything cause the event will be disconnected before the server fires it
end)

task.wait(2)

connection:Disconnect()

```
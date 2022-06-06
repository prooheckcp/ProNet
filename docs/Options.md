---
sidebar_position: 7
---

# 🧊Options

ProNet.Options is a container class used to represent a table that holds additional information given to a new signal.

**Example:**

🟩Server:
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local options : ProNet.Options = {
    signalType = ProNet.SignalType.Event,
    protected = false,
    requestLimit = 5,
    requestResetTime = 3
}

local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", options)
```

**Options List:**

| Name      | Type| Description | Default |
|-----------|-----|-----------------|---------|
|signalType| [``ProNet.SignalType``](#proNet.signalType-🔗)| The type of server-client connection you want to create|ProNet.SignalType.Event |
|protected| ``boolean``| If the data being moved between server-client should be hashed or not| false|
|requestLimit | ``number``| The amount of requests that are allowed via this connection per second | -1 |
|requestResetTime|``number``| Only works if the requestLimit > 0. Changes the time gap between of the request limits in seconds | 1 |

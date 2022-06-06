---
sidebar_position: 1
---

# SignalType 🔗

Simple enum to identify the type of connection that we want to create.

Example:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProNet = require(ReplicatedStorage.ProNet)

local exampleSignalType : ProNet.SignalType = ProNet.SignalType.Event
```

| Name    | Description                              |
|---------|------------------------------------------|
|Event    | Creates a remoteEvent type connection    |
|Function | Creates a remoteFunction type connection |

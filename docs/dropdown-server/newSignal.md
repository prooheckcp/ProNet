---
sidebar_position: 1
---
# ProNet.newSignal 🟪
Creates a new signal (or gets an existing signal with the given name).

**Parameters:**

| Name      |Type               | Description                    |
|-----------|-------------------|--------------------------------|
|signalName |``string``         | The name of the signal         |
|options    |[``ProNet.Options``](#proNet.options-🧊) | The Options for the new signal |

**Returns:**

| Name     |Type              | Description                 |
|----------|------------------|-----------------------------|
|newSignal |[``ProNet.Signal``](#proNet.signal-🧊) | Returns a signal connection |

**Example:**
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event,
    protected = false,
    requestLimit = 5,
    requestResetTime = 3
})
```

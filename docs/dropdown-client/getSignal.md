---
sidebar_position: 1
---

# ProNet.getSignal 🟪
Gets a signal that was created on the server. Works to catch signals created at run-time as well.

**Parameters:**

| Name      |Type       | Description            |
|-----------|-----------|------------------------|
|signalName |``string`` | The name of the signal |

**Returns:**

| Name          |Type              |Description                  |
|---------------|------------------|-----------------------------|
|existingSignal |[``ProNet.Signal``](../category/pronetsignal/) | Returns a signal connection |

**Example:**
```luau
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
```
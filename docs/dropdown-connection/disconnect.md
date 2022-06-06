---
sidebar_position: 1
---

# Connection:Disconnect 🟪

Stops listening to the given event by using the connection object.

Works on both the 🟦Client and the 🟩Server.

**Returns:**

| Name | Type     | Description |
|------|----------|-------------|
|      | ``void`` |             |

**Example:**
```luau
local connection : ProNet.Connection = testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage)
end)

connection:Disconnect()
```
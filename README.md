# ProNet
## A Network manager
ProNet is a signal manager that facilitates the connections between the Client and Server in Roblox. It allows you to create connections between the client and the server without having to manually create and manage remote events/remote functions, instead you can connect the client and the server by using case-sensitive named signals.

On top of this ProNet also allows you to add custom options to the connections to help you dealing with exploiters such as request limits on the signals and base64 encryption on both ways.

## Introduction
This library is composed by 5 different files.

![](https://cdn.discordapp.com/attachments/670023265455964198/979065288932872233/unknown.png)

The only file you need to require at any point is the main ProNet file which can be called from both the client and the server.

```lua
local ProNet = require(ReplicatedStorage.ProNet) --Change to whatever directory you have your ProNet in (recommended: ReplicatedStorage)
```

## Legend

🟩 -> Server

🟦 -> Client

🧊 -> Class

🟪 -> Function

⚡ -> Event

## ProNet (Server) 🧊

### ProNet.newSignal 🟪
Creates a new signal (or gets an existing signal with the given name).

**Parameters**
| Name      |Type               | Description                    |
|-----------|-------------------|--------------------------------|
|signalName |``string``         | The name of the signal         |
|options    |``ProNet.Options`` | The Options for the new signal |

**Returns**
| Name     |Type              | Description                 |
|----------|------------------|-----------------------------|
|newSignal |``ProNet.Signal`` | Returns a signal connection |

**Example:**
```lua
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

## ProNet (Client) 🧊

### ProNet.getSignal 🟪
Gets a signal that was created on the server. Works to catch signals created at run-time as well.

**Parameters**
| Name      |Type       | Description            |
|-----------|-----------|------------------------|
|signalName |``string`` | The name of the signal |

**Returns**
| Name          |Type              |Description                  |
|---------------|------------------|-----------------------------|
|existingSignal |``ProNet.Signal`` | Returns a signal connection |

**Example:**
```lua
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
```

## ProNet.Signal 🧊

### ProNet.Signal:fire 🟪

The :fire function fires all the event listeners on the other side of the connection. If called from the client it will fire all the events attached in the server. If called from the server it will fire all the events attached on the client side. Can take an infinite amount of arguments.

:fire calls wait for clients to load before sending the request meaning you can call the :fire as soon as the player joins the game.

**Parameters**
| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|player    |``player?``| If :fire is called from the server the first argument should be the target client. If called from the client this argument is omitted.
|arguments |``Tuple`` | The arguments passed to the [ProNet.Event](#pronetevent-) method |

**Returns**
| Name     |Type      |Description                                                                                         |
|----------|----------|----------------------------------------------------------------------------------------------------|
|arguments |``Tuple`` | Will return void if the signal is of type Event, can return arguments in case the type is Function |

**Example:**

🟩Server:
```lua
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
```lua
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")

testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage) --Output: Hello from the server!
end)
```

### ProNet.Signal:fireAll 🟪

The :fireAll function can be see as an extension of the :fire function. The main difference is that it fires all the clients instead of a single client when called from the server. This function cannot be called from the 🟦client!

**Parameters**
| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|arguments |``Tuple`` | The arguments passed to the [ProNet.Event](#pronetevent-) method |

**Returns**
| Name | Type | Description |
|------|--------|---------|
|      |``void``| |

**Example:**

🟩Server:
```lua
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
```lua
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")

testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage) --Output: Hello clients!
end)
```

### ProNet.Signal.Event ⚡

This is an event that can be attached to a signal on both the client and the server. It gets called whenever someone :fire's the signal associated to this signal.

**Parameters**
| Name     |Type      | Description                                     |
|----------|----------|-------------------------------------------------|
|player |``Player?`` | If the event is attached in the client this argument won't exist. If attached in the server the first argument will represent the ``Player`` that fire the signal |
|arguments|```Tuple``| The arguments passed thru the network|

**Returns**
| Name      | Type                 | Description |
|-----------|----------------------|---------|
|connection |``ProNet.Connection`` | A connection that represents the event created. Allows you to disconnect the event at any point in the future|

**Example:**

🟩Server:
```lua
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
```lua
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

## Contact 📞

Found any problem or simply wanna give some feedback regarding the library? Just hit me up!

Discord: Prooheckcp#1906
Twitter: https://twitter.com/Prooheckcp


**100% free and open source**
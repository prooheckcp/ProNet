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

## Contact 📞

Found any problem or simply wanna give some feedback regarding the library? Just hit me up!

Discord: Prooheckcp#1906
Twitter: https://twitter.com/Prooheckcp


**100% free and open source**
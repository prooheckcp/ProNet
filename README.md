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

## API (Server) 🧊
The settings file is just a file that allows you to change some of the behaviors from ProStore.

|Setting                   |Description                                                                                          |
|--------------------------|-----------------------------------------------------------------------------------------------------|
|SaveInStudio              |Whether you want the data changed in a studio session to save or not                                 |
|LoadInStudio              |Whether you want the data from the DataStore to be loaded while in a studio session                  |
|OutputWarnings.inStudio   |Whether you want the warnings (usually errors) to output on the console during a studio session      |
|OutputWarnings.inReleased |Whether you want the warnings (usually errors) to output on the console during a normal game session |
|AutoSave.Enabled          |Whether you want the users data to be saved every X amount of minute during his session.             |
|AutoSave.TimeGap          |How often do you want the users data to be saved (In minutes).                                       |
|AutoSave.Notifications    |If you want a notification to be be printed into the console whenever a users data gets saved.       |
|DatabasePrivateKey        |The key that will be used to create your dataStore and access it.                                    |

## API (Client) 🧊
For all of the examples on the API we will be assuming that the schema of our DataBase looks something like this.
```lua

```

## Contact 📞

Found any problem or simply wanna give some feedback regarding the library? Just hit me up!

Discord: Prooheckcp#1906
Twitter: https://twitter.com/Prooheckcp


**100% free and open source**
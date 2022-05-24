--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event,
    protected = false
})

local protectedSignal : ProNet.Signal = ProNet.newSignal("ProtectedSignal", {
    signalType = ProNet.SignalType.Event,
    protected = true
})

local function playerJoined(player : Player)
    task.wait(3)
    print("Sent request!")
    testSignal:fire(player, "Some data", 3, true)
end

Players.PlayerAdded:Connect(playerJoined)
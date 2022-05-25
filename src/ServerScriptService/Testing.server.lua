--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

--Variables
local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event,
    protected = false
})

local protectedSignal : ProNet.Signal = ProNet.newSignal("ProtectedSignal", {
    signalType = ProNet.SignalType.Event,
    protected = true
})

local functionalSignal : ProNet.Signal = ProNet.newSignal("FunctionSignal", {
    signalType = ProNet.SignalType.Function,
    protected = false
})


Players.PlayerAdded:Connect(function(player : Player)
    testSignal:fire(player, "first")
    task.wait(5)
    print("Called again")
    testSignal:fire(player, "second")
end)
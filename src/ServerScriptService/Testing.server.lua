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

testSignal.Event:Connect(function(player : Player, word1, word2)
    print("Test signal from the server")
end)

protectedSignal.Event:Connect(function(player : Player, word1, word2)
    print("Protected signal server!")        
end)

Players.PlayerAdded:Connect(function(player : Player)
    testSignal:fire(player, "Hello world!")
end)
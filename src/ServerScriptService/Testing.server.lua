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

local function playerJoined(player : Player)
    protectedSignal:fire(player, "UwU", "OwO", {value = 3})
end

Players.PlayerAdded:Connect(playerJoined)
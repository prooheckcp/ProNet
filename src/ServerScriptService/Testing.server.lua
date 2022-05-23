--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event
})

local function playerJoined(player : Player)
    testSignal:fire(player, "Some data", 3, true)
end

Players.PlayerAdded:Connect(playerJoined)
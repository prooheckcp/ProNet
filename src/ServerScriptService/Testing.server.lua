--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

ProNet.SignalType
local options : ProNet.Options = {
    signalType = ProNet.SignalType.Event,
    protected = false,
    requestLimit = 5,
    requestResetTime = 3
}

--Variables
local testSignal : ProNet.Signal = ProNet.newSignal("TestSignal", {
    signalType = ProNet.SignalType.Event,
    protected = false,
    requestLimit = 5,
    requestResetTime = 3
})

local protectedSignal : ProNet.Signal = ProNet.newSignal("ProtectedSignal", {
    signalType = ProNet.SignalType.Event,
    protected = true
})

local functionalSignal : ProNet.Signal = ProNet.newSignal("FunctionSignal", {
    signalType = ProNet.SignalType.Function,
    protected = false
})

local connection : ProNet.Connection = testSignal.Event:Connect(function()
    
end)

task.wait(2)

connection:Disconnect()

testSignal:fire()
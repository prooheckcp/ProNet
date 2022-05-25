--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
local protectedSignal : ProNet.Signal = ProNet.getSignal("ProtectedSignal")
local functionalSignal : ProNet.Signal = ProNet.getSignal("FunctionSignal")

task.wait(2)

testSignal:fire("Hellow there!", "Butiful!", "TEST")
protectedSignal:fire("Hello, I'm protected!", "two")
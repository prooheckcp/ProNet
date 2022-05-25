--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
local protectedSignal : ProNet.Signal = ProNet.getSignal("ProtectedSignal")
local functionalSignal : ProNet.Signal = ProNet.getSignal("FunctionSignal")

testSignal:fire()
protectedSignal:fire()

testSignal.Event:Connect(function(message)
    print("Test signal from the client!")
    print(message)
end)
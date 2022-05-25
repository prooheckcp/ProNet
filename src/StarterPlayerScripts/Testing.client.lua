--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
local protectedSignal : ProNet.Signal = ProNet.getSignal("ProtectedSignal")
local functionalSignal : ProNet.Signal = ProNet.getSignal("FunctionSignal")

functionalSignal.Event:Connect(function(message : string)
    print(message)
    return "goodbye"
end)

testSignal.Event:Connect(function(...)
    print(...)
end)

protectedSignal.Event:Connect(function(...)
    print("Protected signal2: ", ...)
end)
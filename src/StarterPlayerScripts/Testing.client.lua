--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)
local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
local protectedSignal : ProNet.Signal = ProNet.getSignal("ProtectedSignal")

protectedSignal.Event:Connect(function(...)
    print("Protected signal2: ", ...)
end)
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local ProNet = require(ReplicatedStorage.ProNet)

local testSignal : ProNet.Signal = ProNet.getSignal("TestSignal")
local protectedSignal : ProNet.Signal = ProNet.getSignal("ProtectedSignal")
local functionalSignal : ProNet.Signal = ProNet.getSignal("FunctionSignal")

testSignal.Event:Connect(function(serverMessage : string)
    print(serverMessage) --Output: Hello from the server!
end)

for i = 0, 10 do
    testSignal:fire()
    task.wait(0.2)
end
--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Signal = require(script.Parent.Signal)

--Variables
local remotesDirectory : Folder = nil 
local ProNet = {
    Signal = Signal
}

function ProNet:init() : nil
    local UUID : string = HttpService:GenerateGUID(false)
    remotesDirectory = Instance.new("Folder")
    remotesDirectory.Name = UUID
    remotesDirectory.Parent = ReplicatedStorage
end

return ProNet
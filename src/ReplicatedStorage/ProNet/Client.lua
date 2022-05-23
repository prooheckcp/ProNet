--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Signal = require(script.Parent.Signal)

--Constants
local ENTRY_POINT_NAME : string = "EntryPointRemoteData"

--Variables
local remotesDirectory : Folder = nil
local remotesIDs : Dictionary<string | string> = {} --Remote name | Remote ID

local privateKey : string = ""
local mainFolderName : string = ""
local signalsDirectories : Dictionary<string | string> = {}

local ProNet = {}

function ProNet:init()
    privateKey = HttpService:GenerateGUID(false)
    local entryRemote : RemoteFunction = ReplicatedStorage[ENTRY_POINT_NAME]
    remotesDirectory, remotesIDs = entryRemote:InvokeServer(privateKey)
end

function ProNet.getSignal(name : string)
    if not signalsDirectories[name] then
        --Check if it was created on run-time
    end
end

--Export types
export type Signal = Signal.Signal

return ProNet
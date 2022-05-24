--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Root folders
local mainFolder = script.Parent
local classes = mainFolder.classes

--Dependencies
local Signal = require(classes.Signal)

--Constants
local SIGNAL_DOES_NOT_EXIST : string = "Requested signal: {name} does not exist!"
local ENTRY_POINT_NAME : string = "EntryPointRemoteData"

--Variables
local remotesDirectory : Folder = nil
local remotesIDs : Dictionary<string | string> = {} --Remote name | Remote ID

local privateKey : string = ""
local signalsDirectories : Dictionary<string | string> = {}

local remotesCount : number = 0

local ProNet = {}

local function newSignalWrapper(signalData : table)
    local newSignal : Signal.Signal = Signal.new()
    newSignal.signalType = signalData.signalType
    newSignal.remote = signalData.remote
    return newSignal
end

local function updateCurrentSignals() : nil
    local entryRemote : RemoteFunction = ReplicatedStorage[ENTRY_POINT_NAME]
    remotesDirectory, remotesIDs = entryRemote:InvokeServer(privateKey)

    for signalName : string, signalData : table in pairs(remotesIDs) do
        if signalsDirectories[signalName] then
            continue
        end

        remotesCount += 1
        signalsDirectories[signalName] = newSignalWrapper(signalData)
    end    
end

function ProNet:init()
    privateKey = HttpService:GenerateGUID(false)
    updateCurrentSignals()
end

function ProNet.getSignal(name : string)
    if not signalsDirectories[name] then
        if #remotesDirectory:GetChildren() <= remotesCount then
            return error(string.gsub(SIGNAL_DOES_NOT_EXIST, "{name}", name))
        end

        --Check if it was created on run-time

        return
    end

    return signalsDirectories[name]
end

--Export types
export type Signal = Signal.Signal

return ProNet
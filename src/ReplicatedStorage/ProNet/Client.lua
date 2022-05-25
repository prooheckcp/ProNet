--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Root folders
local mainFolder = script.Parent
local classes = mainFolder.classes

--Dependencies
local Signal = require(classes.Signal)

--Constants
local ENTRY_POINT_NAME : string = "EntryPointRemoteData"
local LOADING_POINT_NAME : string = "LoadingPointRemote"
local SIGNAL_DOES_NOT_EXIST : string = "Requested signal: {name} does not exist!"
local SUSPICIOUS_ACTIVITY : string = "Suspicious activity. Exploiting is not tolerated. If you believe this is a mistake then contact a developer."

local REQUEST_LIMITS : number = 30
local REQUEST_TIMEOUT : number = 10 --seconds

--Variables
local localPlayer : Player = Players.LocalPlayer
local remotesDirectory : Folder = nil
local remotesIDs : Dictionary<string | string> = {} --Remote name | Remote ID

local privateKey : string = ""
local signalsDirectories : Dictionary<string | string> = {}

local userLoaded : boolean = false
local requestAttempts : number = 0
local remotesCount : number = 0

local ProNet = {}

local function addRequest()
    if requestAttempts >= REQUEST_LIMITS then
        return localPlayer:Kick(SUSPICIOUS_ACTIVITY)
    end
    requestAttempts += 1
    task.delay(REQUEST_TIMEOUT, function()
        requestAttempts -= 1
    end)
end

local function newSignalWrapper(signalData : table)
    local newSignal : Signal.Signal = Signal.new()
    newSignal.signalType = signalData.signalType
    newSignal.remote = signalData.remote
    newSignal.protected = signalData.protected
    newSignal:_load()
    return newSignal
end

local function updateCurrentSignals() : nil
    if remotesDirectory and #remotesDirectory:GetChildren() <= remotesCount then
        return --Invalid update request
    end

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

    if not userLoaded then
        userLoaded = true
        ReplicatedStorage:WaitForChild(LOADING_POINT_NAME):FireServer()
    end
end

function ProNet.getSignal(name : string)
    if not signalsDirectories[name] then
        if #remotesDirectory:GetChildren() <= remotesCount then
            return error(string.gsub(SIGNAL_DOES_NOT_EXIST, "{name}", name))
        end

        --Check if it was created on run-time
        updateCurrentSignals()
        addRequest()
        return ProNet.getSignal(name)
    end

    return signalsDirectories[name]
end

--Export types
export type Signal = Signal.Signal
export type Connection = Signal.Connection

return ProNet
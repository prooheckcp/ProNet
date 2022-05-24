--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Root folders
local mainFolder = script.Parent
local enums = mainFolder.enums
local classes = mainFolder.classes

--Dependencies
local Signal = require(classes.Signal)
local SignalType = require(enums.SignalType)

--Constants
local ALREADY_EXISTS : string = "A signal by the name of: {name} already exists, please avoid reusing signals across server files!"
local ENTRY_POINT_NAME : string = "EntryPointRemoteData"

--Variables
local privateKeys : Dictionary<Player | string> = {}
local entryRemote : RemoteFunction = nil
local remotesDirectory : Folder = nil
local storedSignals : Dictionary<string | Signal.Signal> = {}
local ProNet = {
    SignalType = SignalType
}

local function playerLeft(player : Player)
    privateKeys[player] = nil
end

function ProNet:init() : nil
    local UUID : string = HttpService:GenerateGUID(false)
    remotesDirectory = Instance.new("Folder")
    remotesDirectory.Name = UUID
    remotesDirectory.Parent = ReplicatedStorage

    entryRemote = Instance.new("RemoteFunction")
    entryRemote.Name = ENTRY_POINT_NAME
    entryRemote.Parent = ReplicatedStorage

    entryRemote.OnServerInvoke = function(player : Player, privateKey : string)
        privateKeys[player] = privateKey
        return remotesDirectory, storedSignals
    end
end

function ProNet.newSignal(name : string, options : table) : Signal.Signal
    if storedSignals[name] then
        warn(string.gsub(ALREADY_EXISTS, "{name}", name))
        return storedSignals[name]
    end

    local newSignal : Signal.Signal = Signal.new()
    storedSignals[name] = newSignal

    if options then
        if options.signalType then
            newSignal.signalType = options.signalType
        end
    end

    if newSignal.signalType == SignalType.Event then
        newSignal.remote = Instance.new("RemoteEvent")
    elseif newSignal.signalType == SignalType.Function then
        newSignal.remote = Instance.new("RemoteFunction")
    end

    newSignal.remote.Name = HttpService:GenerateGUID(false)
    newSignal.remote.Parent = remotesDirectory

    newSignal:_load()

    return newSignal
end

--Events
Players.PlayerRemoving:Connect(playerLeft)

--Export types
export type Signal = Signal.Signal

return ProNet
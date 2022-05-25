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
local LOADING_POINT_NAME : string = "LoadingPointRemote"

--Variables
local privateKeys : Dictionary<Player | string> = {}
local loadedUsers : Dictionary<Player | boolean> = {}
local entryRemote : RemoteFunction = nil
local loadedRemote : RemoteEvent = nil
local remotesDirectory : Folder = nil

local storedSignals : Dictionary<string | Signal.Signal> = {}
local ProNet = {
    SignalType = SignalType
}

local function playerLeft(player : Player)
    privateKeys[player] = nil
    loadedUsers[player] = nil
end

function ProNet:init() : nil
    local UUID : string = HttpService:GenerateGUID(false)
    remotesDirectory = Instance.new("Folder")
    remotesDirectory.Name = UUID
    remotesDirectory.Parent = ReplicatedStorage

    entryRemote = Instance.new("RemoteFunction")
    entryRemote.Name = ENTRY_POINT_NAME
    entryRemote.Parent = ReplicatedStorage

    loadedRemote = Instance.new("RemoteEvent")
    loadedRemote.Name = LOADING_POINT_NAME
    loadedRemote.Parent = ReplicatedStorage

    loadedRemote.OnServerEvent:Connect(function(player : Player)
        loadedUsers[player] = true
    end)

    entryRemote.OnServerInvoke = function(player : Player, privateKey : string)
        privateKeys[player] = privateKey
        return remotesDirectory, storedSignals
    end

    Signal.loadedUsers = loadedUsers --pass by reference
    Signal.privateKeys = privateKeys --pass by reference
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
        if options.protected then
            newSignal.protected = true
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
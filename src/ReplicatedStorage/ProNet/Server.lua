--Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Root folders
local enums = script.Parent.enums

--Dependencies
local Signal = require(script.Parent.Signal)
local SignalType = require(enums.SignalType)

--Constants
local ALREADY_EXISTS : string = "A signal by the name of: {name} already exists, please avoid reusing signals across server files!"

--Variables
local remotesDirectory : Folder = nil
local storedSignals : Dictionary<string | Signal.Signal> = {}
local ProNet = {
    SignalType = SignalType
}

function ProNet:init() : nil
    local UUID : string = HttpService:GenerateGUID(false)
    remotesDirectory = Instance.new("Folder")
    remotesDirectory.Name = UUID
    remotesDirectory.Parent = ReplicatedStorage
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

    return newSignal
end

--Export types
export type Signal = Signal.Signal

return ProNet
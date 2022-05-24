--[[
    Holds the signals class
]]

--Services
local RunService = game:GetService("RunService")

--Root folders
local mainFolder = script.Parent.Parent
local enums = mainFolder.enums

--Dependencies
local SignalType = require(enums.SignalType)

export type Callback = {(callback : any) -> any}

export type Event = {
    Super : any,
    Connect : Callback
}

export type Signal = {
    remote : RemoteEvent | RemoteFunction,
    signalType : SignalType.SignalType,
    _load : ()->nil,
    protected : boolean,
    Event : Event,
    eventListener : RBXScriptSignal,
    attachedCallbacks : Array<Callback> | Callback
}

--Constants
local FIRE_ALL_FUNCTION : string = "Fire All cannot be called on RemoteFunctions, only on RemoteEvents!"
local REMOTE_NOT_FOUND : string = "Internal Error! Could not find remote instance!"
local WARNING_OVERRIDING_CALLBACK : string = "Warning! You're overriding the callback of a remote function!"

--Variables
local Signal : Signal = {}
Signal.remote = nil
Signal.protected = false
Signal.signalType = SignalType.Event
Signal.Event = {}
Signal.eventListener = nil
Signal.attachedCallbacks = nil

--[=[
    Creates a new signal connection between the client and the
    server
]=]
function Signal.new()
    local self = setmetatable({}, {__index = Signal})
    self.new = nil -- Do not expose the new method

    self.Event.Super =self

    return self
end

--[=[
    Load the data of the signal
]=]
function Signal:_load() : nil
    if not self.remote then
        return error(REMOTE_NOT_FOUND)
    end

    --Set callback format
    if self.signalType == SignalType.Event then
        self.attachedCallbacks = {}
    elseif self.signalType == SignalType.Function then
        self.attachedCallbacks = nil
    end

    if RunService:IsServer() then
        if self.signalType == SignalType.Event then
            self.remote.OnServerEvent:Connect(function(...)
                for _, callback : Callback in pairs(self.attachedCallbacks) do
                    callback(...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnServerInvoke = function(...)
                if self.attachedCallbacks then
                    return self.attachedCallbacks(...)
                end
            end
        end
    elseif RunService:IsClient() then
        if self.signalType == SignalType.Event then
            self.remote.OnClientEvent:Connect(function(...)
                for _, callback : Callback in pairs(self.attachedCallbacks) do
                    callback(...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnClientInvoke:Connect(function(...)
                if self.attachedCallbacks then
                    return self.attachedCallbacks(...)
                end
            end)
        end
    end
    self.load = nil
end

--[=[
    Fires a single client with custom data
]=]
function Signal:fire(player : Player, ...) : any
    if self.signalType == SignalType.Event then
        self.remote:FireClient(player, ...)
    elseif self.signalType == SignalType.Function then
        return self.remote:InvokeClient(player, ...)
    end 
end

function Signal:fireAll(...)
    if self.signalType == SignalType.Function then
        return error(FIRE_ALL_FUNCTION)
    elseif self.signalType == SignalType.Event then
        self.remote:FireAllClients(...)
    end
end

--[=[
    Creates a new signal connection between the client and the
    server
]=]
function Signal.Event:Connect(callback : (any) -> any)
    if typeof(callback) ~= "function" then
        return
    end

    if self.Super.signalType == SignalType.Function then
        if self.Super.AttachedCallbacks ~= nil then
            warn(WARNING_OVERRIDING_CALLBACK)
        end
        self.Super.AttachedCallbacks = callback
    elseif self.Super.signalType == SignalType.Event then
        table.insert(self.Super.AttachedCallbacks, callback)
    end
end

return Signal
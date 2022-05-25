--[[
    Holds the signals class
]]

--Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--Root folders
local mainFolder = script.Parent.Parent
local enums = mainFolder.enums

--Dependencies
local SignalType = require(enums.SignalType)
local HashLib = require(mainFolder.HashLib)

export type Callback = {(callback : any) -> any}

export type Event = {
    Connect : Callback,
    Super : any,
    attachedCallbacks : Array<Callback> | Callback
}

export type Signal = {
    remote : RemoteEvent | RemoteFunction,
    signalType : SignalType.SignalType,
    _load : ()->nil,
    protected : boolean,
    Event : Event,
    eventListener : RBXScriptSignal
}

--Constants
local FIRE_ALL_FUNCTION : string = "Fire All cannot be called on RemoteFunctions, only on RemoteEvents!"
local REMOTE_NOT_FOUND : string = "Internal Error! Could not find remote instance!"
local WARNING_OVERRIDING_CALLBACK : string = "Warning! You're overriding the callback of a remote function!"
local YIELDING_LIMIT : number = 10 -- seconds

--Variables
local Signal : Signal = {}
Signal.loadedUsers = nil
Signal.privateKeys = nil
Signal.remote = nil
Signal.protected = false
Signal.signalType = SignalType.Event
Signal.Event = nil
Signal.eventListener = nil

--[=[
    Creates a new signal connection between the client and the
    server
]=]
function Signal.new()
    local self = setmetatable({
        Event = {}
    }, {__index = Signal})

    self.new = nil -- Do not expose the new method

    --[=[
        Creates a new signal connection between the client and the
        server
    ]=]
    self.Event.Connect = function(_, callback : (any) -> any)
        if typeof(callback) ~= "function" then
            return
        end

        if self.signalType == SignalType.Function then
            if self.Event.attachedCallbacks ~= nil then
                warn(WARNING_OVERRIDING_CALLBACK)
            end
            self.Event.attachedCallbacks = callback
        elseif self.signalType == SignalType.Event then
            table.insert(self.Event.attachedCallbacks, callback)
        end
    end

    return self
end

--[=[
    Callback wrapper for possible middleware steps
    such as decryption
]=]
function Signal:_callback(callback : (any)->any, ...)
    if self.protected then
        local unhashedData : string = HashLib.base64_decode(({...})[1])
        local decodedData : any = HttpService:JSONDecode(unhashedData)
        return callback(table.unpack(decodedData))
    else
        return callback(...)
    end
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
        self.Event.attachedCallbacks = {}
    elseif self.signalType == SignalType.Function then
        self.Event.attachedCallbacks = nil
    end

    if RunService:IsServer() then
        if self.signalType == SignalType.Event then
            self.remote.OnServerEvent:Connect(function(...)
                for _, callback : Callback in pairs(self.Event.attachedCallbacks) do
                    self:_callback(callback, ...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnServerInvoke = function(...)
                if self.Event.attachedCallbacks then
                    return self:_callback(self.Event.attachedCallbacks, ...)
                end
            end
        end
    elseif RunService:IsClient() then
        if self.signalType == SignalType.Event then
            self.remote.OnClientEvent:Connect(function(...)
                for _, callback : Callback in pairs(self.Event.attachedCallbacks) do
                    self:_callback(callback, ...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnClientInvoke = function(...)
                if self.Event.attachedCallbacks then
                    return self:_callback(self.Event.attachedCallbacks, ...)
                end
            end
        end
    end
    self.load = nil
end

--[=[
    Fires a single client with custom data
]=]
function Signal:fire(player : Player, ...) : any
    if not self.loadedUsers[player] then
        if player.Parent == Players then
            local yieldingCounter = 0
            repeat
                yieldingCounter += task.wait()
                if yieldingCounter > YIELDING_LIMIT then
                    break
                end
            until
                self.loadedUsers[player]
        end        
    end

    local hashedData : string = nil
    if self.protected then
        local jsonEncoded : string = HttpService:JSONEncode({...})
        hashedData = HashLib.base64_encode(jsonEncoded)
    end

    if self.signalType == SignalType.Event then
        self.remote:FireClient(player, hashedData or ...)
    elseif self.signalType == SignalType.Function then
        return self.remote:InvokeClient(player, hashedData or ...)
    end
end

function Signal:fireAll(...)
    if self.signalType == SignalType.Function then
        return error(FIRE_ALL_FUNCTION)
    elseif self.signalType == SignalType.Event then
        for _, player : Player in pairs(Players:GetPlayers()) do
            self:fire(player, ...)
        end
    end
end

return Signal
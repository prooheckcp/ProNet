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

local function encrytUnpackedData(...)
    local jsonEncoded : string = HttpService:JSONEncode(...)
    return HashLib.base64_encode(jsonEncoded)
end

local function decryptData(hashedData : string)
    local unhashedData = HashLib.base64_decode(hashedData)
    return table.unpack(HttpService:JSONDecode(unhashedData))
end

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

function Signal:_callbackClient(callback : (any, any)->nil, ...)
    if self.protected then
        return callback(decryptData(({...})[1]))
    else
        return callback(...)
    end
end

function Signal:_callbackServer(callback : (any, any)->nil, player : Player, ...)
    if self.protected then
        return callback(player, decryptData(({...})[1]))
    else
        return callback(player, table.unpack(...))
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
            self.remote.OnServerEvent:Connect(function(player : Player, ...)
                for _, callback : Callback in pairs(self.Event.attachedCallbacks) do
                    self:_callbackServer(callback, player, ...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnServerInvoke = function(player : Player, ...)
                if self.Event.attachedCallbacks then
                    return self:_callbackServer(self.Event.attachedCallbacks, player, ...)
                end
            end
        end
    elseif RunService:IsClient() then
        if self.signalType == SignalType.Event then
            self.remote.OnClientEvent:Connect(function(...)
                for _, callback : Callback in pairs(self.Event.attachedCallbacks) do
                    self:_callbackClient(callback, ...)
                end
            end)
        elseif self.signalType == SignalType.Function then
            self.remote.OnClientInvoke = function(...)
                if self.Event.attachedCallbacks then
                    return self:_callbackClient(self.Event.attachedCallbacks, ...)
                end
            end
        end
    end
    self.load = nil
end

--[=[
    Fires the server. Used as an alternative endpoint for the :Fire method
]=]
function Signal:_fireServer(...)
    if self.signalType == SignalType.Event then
        self.remote:FireServer(self.protected and encrytUnpackedData(...) or ...)
    elseif self.signalType == SignalType.Function then
        return self.remote:InvokeServer(self.protected and encrytUnpackedData(...) or ...)
    end
end

--[=[
    Fires the client. Used as an alternative endpoint for the :Fire method
]=]
function Signal:_fireClient(player : Player, ...)
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



    if self.signalType == SignalType.Event then
        self.remote:FireClient(player, self.protected and encrytUnpackedData(...) or ...)
    elseif self.signalType == SignalType.Function then
        return self.remote:InvokeClient(player, self.protected and encrytUnpackedData(...) or ...)
    end
end

--[=[
    Fires either the server or the client
]=]
function Signal:fire(player : Player, ...) : any
    if RunService:IsClient() then
        local packedData : table = table.pack(player, ...)
        packedData["n"] = nil
        return self:_fireServer(packedData)
    elseif RunService:IsServer() then
        return self:_fireClient(player, ...)
    end
end

--[=[
    Fires all the clients with custom data
]=]
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
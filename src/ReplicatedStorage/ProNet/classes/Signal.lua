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

export type Connection = {
    Disconnect : (self : Connection) -> nil
}
export type Callback = {(callback : any) -> any}
export type Event = {
    Connect : (self : Event, Callback) -> nil
}

export type Signal = {
    Event : Event,
    fire : (self : Signal, any) -> any,
    fireAll : (self : Signal, any) -> nil
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

local function encrytUnpackedData(...) : string
    local jsonEncoded : string = HttpService:JSONEncode(#{...} > 1 and {...} or ...)
    return HashLib.base64_encode(jsonEncoded)
end

local function decryptData(hashedData : string) : nil | string
    if typeof(hashedData) ~= "string" then
        return nil
    end

    local unhashedData : string = HashLib.base64_decode(hashedData)
    local decodedData : any = HttpService:JSONDecode(unhashedData)
    
    if typeof(decodedData) == "table" then
        return table.unpack(decodedData)
    else
        return decodedData
    end
end

--[=[
    Creates a new signal connection between the client and the
    server
]=]
function Signal.new() : Signal
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

        return {Disconnect = function(_)
            if self.signalType == SignalType.Event then
                for index : number, _callback in pairs(self.Event.attachedCallbacks) do
                    if _callback == callback then
                        table.remove(self.Event.attachedCallbacks, index)
                        break
                    end
                end
            elseif self.signalType == SignalType.Function then
                self.Event.attachedCallbacks = nil
            end
        end}
    end

    return self
end

function Signal:_callbackClient(callback : (any, any)->nil, ...)
    if self.protected then
        if #{...} <= 0 then
            return callback()
        else
            return callback(decryptData(({...})[1]))
        end
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
        self.remote:FireServer((self.protected and #{...} > 0) and encrytUnpackedData(...) or ...)
    elseif self.signalType == SignalType.Function then
        return self.remote:InvokeServer((self.protected and #{...} > 0) and encrytUnpackedData(...) or ...)
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

    local dataToSend : any = (self.protected and #{...} > 0) and encrytUnpackedData(...) or {...}
    local isTable : boolean = typeof(dataToSend) == "table"

    if self.signalType == SignalType.Event then
        if isTable then
            self.remote:FireClient(player, table.unpack(dataToSend))
        else
            
            self.remote:FireClient(player, dataToSend)
        end      
    elseif self.signalType == SignalType.Function then
        if isTable then
            return self.remote:InvokeClient(player, table.unpack(dataToSend))
        else
            return self.remote:InvokeClient(player, dataToSend)
        end
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
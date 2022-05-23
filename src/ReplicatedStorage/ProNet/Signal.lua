--[[
    Holds the signals class
]]

--Root folders
local mainFolder = script.Parent
local enums = mainFolder.enums

--Dependencies
local SignalType = require(enums.SignalType)

export type Signal = {
    remote : RemoteEvent | RemoteFunction,
    signalType : SignalType.SignalType,
    protected : boolean
}

--Constants
local FIRE_ALL_FUNCTION : string = "Fire All cannot be called on RemoteFunctions, only on RemoteEvents!"

--Variables
local Signal : Signal = {}
Signal.remote = nil
Signal.protected = false
Signal.signalType = SignalType.Event

--[=[
    Creates a new signal connection between the client and the
    server
]=]
function Signal.new()
    local self = setmetatable({}, {__index = Signal})
    self.new = nil -- Do not expose the new method

    return self
end

--[=[
    Fires a single client
]=]
function Signal:fire(player : Player, ...) : any
    self.remote:FireClient(player, ...)
end

function Signal:fireAll(...)
    if self.signalType == SignalType.Function then
        return error(FIRE_ALL_FUNCTION)
    end

    self.remote:FireAllClients(...)
end

return Signal
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
    signalType : SignalType.SignalType
}

local Signal : Signal = {}
Signal.remote = nil
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
function Signal:fire(player : Player, ...)
    
end

function Signal:fireAll(...)
    
end

return Signal
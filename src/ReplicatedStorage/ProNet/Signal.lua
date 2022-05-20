--[[
    Holds the signals class
]]

local Signal = {}

function Signal.new()
    local self = setmetatable({

    }, {__index = Signal})

    self.new = nil -- Do not expose the new method

    return self
end

return Signal
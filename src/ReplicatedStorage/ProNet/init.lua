--Services
local RunService = game:GetService("RunService")

--Dependencies
local Client = require(script.Client)
local Server = require(script.Server)

--Variables
local isClient : boolean = RunService:IsClient()
local isServer : boolean = RunService:IsServer()

if isClient then
    Client:init()
    return Client
elseif isServer then
    Server:init()
    return Server
else
    return error("ProNet got externally called?")
end
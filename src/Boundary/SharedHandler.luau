local RunService = game:GetService "RunService"

local Amplified = require "../Amplified/Amplified"
local Log = require "../Log"
local Garbage = require "../State/Garbage"
local Types = require "../Types"
local deepMerge = require "../deepMerge"
--local Sera = require "./Sera"

local SharedReq = script.Parent.SharedReq

--[[
TODO:

write a handler for sharedReq
create shared amplified on both parts

if this script is ran on the server, then allow requests
else, create a warning

if this script is ran on the server, dont connect
else, connect to sharedReq, deserialize buffer and detect changes
(amplified keys can be strings from 1-15 letters and numbers from 0 to 255)

if this script is ran on the server, then return ABSTRACTED UNREADABLE IN CODE API To modify the shared amplified
DO NOT COMMIT UNABSTRACTED CODE SESSIONS. KEEP AN UNTRACKED FILE WITH UNABSTRACTED CODE.

actually why abstract if its server-only networks
]]

local _ISSERVER = RunService:IsServer()

local _SHAREDGARBAGE = Garbage()

local Shared = (function()
	local self = Amplified(_SHAREDGARBAGE, {
		--...
	})

	self.__replications = {} :: { [Player]: Types.Amplified<unknown, unknown> }

	local function generateSchema(values)
		--local schema = {} :: { [string]: Sera.SeraType }

		-- generate schema based on best recommendations

		--tests:
		--print(generateSchema { myval = 1, haaha = -999 })
	end

	function self:All(values: {})
		--...
		--serialize buffer and replicate to clientside Alloy
	end

	function self:For(player: Player, values: {})
		--...
		local schema = generateSchema(values)

		-- custom schema like  shared:For {plr1, plr2} {myvalue = {Sera.String16, 'Hello world!'} }

		-- schema generated, next TODO
		-- send 2 serialized buffers, the first one is the schema itself, serialize into string

		-- actually make this schema generation a function because itll be used in shared:All
		-- also whenever new player is added into __replications, give their amplified a connection so that itll automatically replicate the same way
		-- thatll be discouraged for multiple values though, like  `shared:getFor(plr1).myval = 1` will replicate and the same is `shared:For {plr1} {myval = 1}`

		--
	end

	function self:getFor(player: Player)
		--self.__replications[player] will override
		--return deepMerge(self.__value, self.__replications[player])
		--edit: this decision is superseded due to subscribing to a specific player's vision of the Shared.

		return self.__replications[player]
	end

	return self :: Types.SharedAmplified
end)()

return function(tbl: {})
	if not _ISSERVER then
		Log.logError "clientsideSharedMod"
	end
	if typeof(tbl) ~= "table" then
		Log.logError "strangeSharedMod"
	end

	print(tbl)
end

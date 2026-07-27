--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)
local calls = {}

local AlphaService = Nerve.CreateService({
	Name = "TestAlphaService",
	Client = {},
})

local BetaService = Nerve.CreateService({
	Name = "TestBetaService",
	Client = {},
})

function AlphaService:NerveInit()
	assert(Nerve.GetService("TestBetaService") == BetaService, "Services must be available during initialization")
	table.insert(calls, "AlphaInit")
end

function BetaService:NerveInit()
	table.insert(calls, "BetaInit")
	return Nerve.Promise.resolve()
end

function AlphaService:NerveStart()
	table.insert(calls, "AlphaStart")
end

function BetaService:NerveStart()
	return Nerve.Promise.try(function()
		table.insert(calls, "BetaStart")
	end)
end

return function()
	local earlyOnStart = Nerve.OnStart()
	local started, startReason = Nerve.Start():await()

	assert(started, tostring(startReason))

	local earlyResolved, earlyReason = earlyOnStart:await()
	assert(earlyResolved, tostring(earlyReason))

	assert(#calls == 4, `Expected four lifecycle calls, received {#calls}`)
	assert(calls[1] == "AlphaInit" and calls[2] == "BetaInit", "Initialization must begin in service-name order")
	assert(calls[3] == "AlphaStart" and calls[4] == "BetaStart", "Start must begin after initialization")
end

--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = ReplicatedStorage.Nerve
local Lifecycle = require(Nerve.Lifecycle)
local Promise = require(Nerve.Dependencies.Promise)

return function()
	local calls = {}
	local objects = {
		Second = {
			Name = "Second",
			NerveInit = function(self)
				table.insert(calls, self.Name)
				return Promise.resolve()
			end,
		},
		Skipped = {
			Name = "Skipped",
		},
		First = {
			Name = "First",
			NerveInit = function(self)
				table.insert(calls, self.Name)
			end,
		},
	}

	local initialized, initializationReason = Lifecycle.Run(objects, "NerveInit", "service", Promise):await()
	assert(initialized, tostring(initializationReason))
	assert(#calls == 2, `Expected two lifecycle calls, received {#calls}`)
	assert(calls[1] == "First" and calls[2] == "Second", "Lifecycle objects must begin in name order")

	local started = false
	local startSucceeded, startReason = Lifecycle.Run({
		Example = {
			Name = "Example",
			NerveStart = function()
				return Promise.try(function()
					started = true
				end)
			end,
		},
	}, "NerveStart", "controller", Promise):await()

	assert(startSucceeded, tostring(startReason))
	assert(started, "Lifecycle must adopt promises returned by hooks")

	local failed, failureReason = Lifecycle.Run({
		Broken = {
			Name = "Broken",
			NerveInit = function()
				error("expected failure")
			end,
		},
	}, "NerveInit", "service", Promise):await()

	assert(not failed, "A lifecycle hook error must reject its phase")

	local failureMessage = tostring(failureReason)
	assert(string.find(failureMessage, 'service "Broken"', 1, true), failureMessage)
	assert(string.find(failureMessage, "NerveInit", 1, true), failureMessage)
	assert(string.find(failureMessage, "expected failure", 1, true), failureMessage)
end

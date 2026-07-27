--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)

return function()
	local defaultMethod = Nerve.Method()
	assert(defaultMethod.rateLimit.requests == 30, "Methods must have a default request limit")
	assert(defaultMethod.rateLimit.window == 1, "Method request window must default to one second")

	local unlimitedMethod = Nerve.Method({
		RateLimit = false,
	})
	assert(unlimitedMethod.rateLimit == nil, "RateLimit = false must disable method limiting")

	local defaultSignal = Nerve.Signal(nil, {
		Direction = "client",
	})
	assert(defaultSignal.rateLimit.requests == 60, "Client signals must have a default event limit")
	assert(defaultSignal.rateLimit.window == 1, "Signal event window must default to one second")

	local configuredSignal = Nerve.Signal(nil, {
		Direction = "duplex",
		RateLimit = {
			Requests = 12,
			Window = 2,
		},
	})
	assert(configuredSignal.rateLimit.requests == 12, "Signal request limit must preserve configuration")
	assert(configuredSignal.rateLimit.window == 2, "Signal request window must preserve configuration")
end

--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkPolicy = require(ReplicatedStorage.Nerve.NetworkPolicy)

return function()
	NetworkPolicy.ValidateMiddleware({
		Inbound = {
			function()
				return true
			end,
		},
	}, "Test middleware")

	local original = table.pack(4, "untouched")
	local allowedWithoutMiddleware, unchanged = NetworkPolicy.RunMiddleware(nil, nil, original)
	assert(allowedWithoutMiddleware and unchanged == original, "Missing middleware must preserve arguments")

	local allowed, transformed = NetworkPolicy.RunMiddleware({
		function(args)
			return true, args[1] + 1, args[2]
		end,
		function(args)
			return true, args[1] * 2, args[2]
		end,
	}, nil, original)

	assert(allowed, "Middleware chain should allow the request")
	assert(transformed.n == 2 and transformed[1] == 10 and transformed[2] == "untouched", "Middleware must compose")

	local rejected = NetworkPolicy.RunMiddleware({
		function()
			return false
		end,
	}, nil, original)
	assert(not rejected, "Middleware must be able to reject traffic")

	local bucket = {}
	local key = {}
	local limit = {
		requests = 2,
		window = 1,
	}

	assert(NetworkPolicy.CheckRate(bucket, key, limit, 10), "First request should pass")
	assert(NetworkPolicy.CheckRate(bucket, key, limit, 10.1), "Second request should pass")
	assert(not NetworkPolicy.CheckRate(bucket, key, limit, 10.2), "Excess request should be rejected")
	assert(NetworkPolicy.CheckRate(bucket, key, limit, 11), "A new window should reset the bucket")

	local globalMiddleware = {}
	local serviceMiddleware = {}
	assert(
		NetworkPolicy.ResolveMiddleware(globalMiddleware, serviceMiddleware) == serviceMiddleware,
		"Service middleware must override global middleware"
	)
	assert(
		NetworkPolicy.ResolveMiddleware(globalMiddleware, nil) == globalMiddleware,
		"Global middleware must be the fallback"
	)
end

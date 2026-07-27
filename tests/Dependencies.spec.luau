--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)

return function()
	local profileStore = Nerve.GetDependency("ProfileStore")

	assert(type(profileStore) == "table", "ProfileStore must load through Nerve.GetDependency")
	assert(type(profileStore.New) == "function", "ProfileStore.New must be available")
	assert(type(profileStore.SetConstant) == "function", "ProfileStore.SetConstant must be available")
end

---
sidebar_position: 6
sidebar_label: ProfileStore
---

# ProfileStore

Nerve bundles ProfileStore 1.0.3 for server-owned player persistence. Load it
through Nerve's public dependency API instead of reaching into the package tree.

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)
local ProfileStore = Nerve.GetDependency("ProfileStore")

local PlayerStore = ProfileStore.New("PlayerProfiles", {
	Coins = 0,
	Experience = 0,
})

local profiles = {}

local function loadProfile(player)
	local profile = PlayerStore:StartSessionAsync(`Player_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if not profile then
		player:Kick("Your data could not be loaded. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Your data was opened on another server. Please rejoin.")
		end
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	profiles[player] = profile
end

Players.PlayerAdded:Connect(loadProfile)
Players.PlayerRemoving:Connect(function(player)
	local profile = profiles[player]
	if profile then
		profiles[player] = nil
		profile:EndSession()
	end
end)
```

ProfileStore is server-only. The server must validate every client-requested
mutation and replicate only an allow-listed snapshot.

## Durable transaction confirmation

`Profile.LastSavedData` is the last profile snapshot confirmed by DataStore.
For developer products or other critical grants, put a monotonic commit marker
inside `Profile.Data`, call `Profile:Save()`, and confirm that the marker appears
in `LastSavedData` before acknowledging the transaction.

## Migrating from ProfileService

Keep the same DataStore name and profile keys. ProfileStore can read existing
ProfileService profiles. Replace the main API calls as follows:

| ProfileService | ProfileStore |
| --- | --- |
| `GetProfileStore(name, template)` | `New(name, template)` |
| `LoadProfileAsync(key, "ForceLoad")` | `StartSessionAsync(key, { Cancel = ... })` |
| `ListenToRelease(callback)` | `OnSessionEnd:Connect(callback)` |
| `Release()` | `EndSession()` |
| `MetaData.MetaTagsLatest` | `LastSavedData` |

Test the migration in Studio with API access before deploying it to a live
production store. Avoid switching back to ProfileService after ProfileStore has
written newer profile features.

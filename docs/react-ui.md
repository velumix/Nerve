---
sidebar_position: 6
sidebar_label: React UI
---

# React UI

Nerve bundles React and ReactRoblox so a game can build declarative interfaces
without installing or copying another runtime. Roact is deprecated; new Nerve
interfaces should use React.

Retrieve both modules through Nerve. Do not require their internal package
folders:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)
local React = Nerve.GetDependency("React")
local ReactRoblox = Nerve.GetDependency("ReactRoblox")
```

## Mount from a controller

A controller is the lifecycle boundary between Nerve state and the React tree.
It resolves services and other controllers, mounts one root, and unmounts that
root during cleanup.

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Nerve)
local React = Nerve.GetDependency("React")
local ReactRoblox = Nerve.GetDependency("ReactRoblox")

local e = React.createElement
local UIController = Nerve.CreateController({ Name = "UIController" })

local function App()
	return e("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Title = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = "Ready",
		}),
	})
end

function UIController:NerveStart()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._root = ReactRoblox.createRoot(Instance.new("Folder"))
	self._root:render(ReactRoblox.createPortal(e(App), playerGui))
end

function UIController:Destroy()
	if self._root then
		self._root:unmount()
		self._root = nil
	end
end

return UIController
```

## State ownership

Keep authoritative game state in server services. Client controllers should
cache typed Nerve responses and signals, then expose that state to React through
props, context, or a small hook. Local presentation state such as the selected
tab or an open modal can remain inside React.

```text
Server service -> typed Nerve contract -> client controller -> React tree
```

Avoid calling remote methods during render. Resolve initial state in the
controller or a hook effect, subscribe to service signals once, and clean up the
subscription when the component or controller unmounts.

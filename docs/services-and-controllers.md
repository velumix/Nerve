---
sidebar_position: 2
sidebar_label: Services and controllers
---

# Services and controllers

Services organize server systems. Controllers organize client systems. Both use
the same two-stage lifecycle:

1. `NerveInit` runs for every object and may yield.
2. `NerveStart` runs after all initialization completes.
3. Nerve reports ready only after every lifecycle hook finishes successfully.

The bundled RunContext bootstraps automatically load these modules from the
configured service and controller folders before starting Nerve.

```text
Discover modules -> NerveInit every object -> NerveStart every object -> ready
```

Hooks in each phase begin in object-name order and run concurrently through
cancellable promises. A hook may return a Nerve Promise; startup adopts that
promise and waits for it. If a hook throws or returns a rejected promise,
`Start()` and `OnStart()` reject with the object's name and failed phase.

`NerveStart` should connect events and launch intentionally long-lived work,
then return. Do not keep the hook itself alive as a permanent loop.

:::important
Create and return lifecycle objects from their modules. Do not call
`Nerve.Start()` inside a service or controller; the packaged bootstraps own
startup.
:::

## Server service

```luau title="ServerScriptService/Services/InventoryService.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nerve = require(ReplicatedStorage.Packages.Nerve)

local InventoryService = Nerve.CreateService({
	Name = "InventoryService",
	Client = {},
})

function InventoryService:NerveInit()
	self.Inventories = {}
end

function InventoryService:NerveStart()
	print("InventoryService started")
end

return InventoryService
```

Use `Nerve.GetService("InventoryService")` from another service after startup.
The default bootstrap loads direct child ModuleScripts. Set the
`DeepServiceDiscovery` attribute to `true` to recursively load descendants.

## Client controller

```luau title="ReplicatedStorage/Client/Controllers/InventoryController.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nerve = require(ReplicatedStorage.Packages.Nerve)

local InventoryController = Nerve.CreateController({
	Name = "InventoryController",
})

function InventoryController:NerveInit()
	self.InventoryService = Nerve.GetService("InventoryService")
end

function InventoryController:NerveStart()
	print("InventoryController started")
end

return InventoryController
```

Use `Nerve.GetController(name)` to retrieve another controller.
The default bootstrap loads direct children. Set `DeepControllerDiscovery` to
`true` to recursively load descendants.

## Waiting for startup

Code outside the bootstrap can wait without racing lifecycle execution:

```luau
Nerve.OnStart():andThen(function()
	local InventoryService = Nerve.GetService("InventoryService")
	-- Safe to use initialized state here.
end):catch(warn)
```

`Start` and `OnStart` return Nerve's bundled Promise implementation. Both
resolve at the same readiness boundary and reject on lifecycle failure.

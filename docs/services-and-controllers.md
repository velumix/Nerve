---
sidebar_position: 2
---

# Services and controllers

Services organize server systems. Controllers organize client systems. Both use
the same two-stage lifecycle:

1. `NerveInit` runs for every object and may yield.
2. `NerveStart` runs after all initialization completes and is spawned in its
   own task.

The bundled RunContext bootstraps automatically load these modules from the
configured service and controller folders before starting Nerve.

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

`Start` and `OnStart` return Nerve's bundled Promise implementation.

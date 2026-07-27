---
sidebar_position: 3
sidebar_label: Typed networking
---

# Typed networking

Nerve builds deterministic ByteNet packets from a service's `Network` contract.
The server publishes a compact manifest; clients reconstruct the same packet
definitions without receiving server service source.

| Contract | Direction | Client surface |
|---|---|---|
| `Nerve.Method` | Client request to server response | Cancellable promise |
| Server signal | Server to one or more clients | `Connect` |
| Client signal | Client to server | `Fire` |
| Duplex signal | Both directions | `Connect` and `Fire` |

## Request and response methods

Define a contract and implement the matching function on the service's `Client`
table:

```luau
local S = Nerve.Schema

local InventoryService = Nerve.CreateService({
	Name = "InventoryService",
	Client = {},
	Network = {
		Equip = Nerve.Method({
			Request = S.Tuple({ S.String }),
			Response = S.Tuple({ S.Boolean, S.Optional(S.String) }),
			Timeout = 8,
			RateLimit = {
				Requests = 12,
				Window = 1,
			},
		}),
	},
})

function InventoryService.Client:Equip(player, itemId)
	if itemId == "" then
		return false, "Invalid item"
	end

	return true, nil
end
```

Call it from the client:

```luau
local InventoryService = Nerve.GetService("InventoryService")

InventoryService:Equip("sword"):andThen(function(equipped, reason)
	if not equipped then
		warn(reason)
	end
end):catch(warn)
```

Client calls are cancellable promises. Nerve enforces the declared timeout, caps
each endpoint at 128 in-flight client calls, applies optional per-player server
rate limits, and sends sanitized error codes instead of server traces.

`Request` and `Response` default to `Schema.Packed` for gradual migration, but
explicit schemas are recommended.

## Signals

Signals live directly in the service's `Client` table. They are reliable and
server-to-client by default:

```luau
local InventoryService = Nerve.CreateService({
	Name = "InventoryService",
	Client = {
		InventoryChanged = Nerve.Signal(
			S.Tuple({ S.Array(S.String) })
		),
	},
})
```

On the server:

```luau
InventoryService.Client.InventoryChanged:Fire(player, itemIds)
InventoryService.Client.InventoryChanged:FireAll(itemIds)
InventoryService.Client.InventoryChanged:FireExcept(player, itemIds)
InventoryService.Client.InventoryChanged:FireList(players, itemIds)
```

On the client:

```luau
InventoryService.InventoryChanged:Connect(function(itemIds)
	print(`Received {#itemIds} items`)
end)
```

Set `Direction = "client"` for client-to-server traffic or `"duplex"` for both
directions. Client-to-server signals should only be enabled when the server
genuinely needs fire-and-forget input:

```luau
local AimService = Nerve.CreateService({
	Name = "AimService",
	Client = {
		AimChanged = Nerve.Signal(
			S.Tuple({ S.Vector3 }),
			{
				Direction = "client",
				Reliability = "unreliable",
			}
		),
	},
})
```

A client-directed signal exposes `:Fire(...)` on the client and
`:Connect(function(player, ...) end)` on the server.

:::caution
Schemas reduce bandwidth and reject malformed serialization shapes, but they do
not make client input trustworthy. Validate permissions, ownership, distance,
state, and game rules on the server.
:::

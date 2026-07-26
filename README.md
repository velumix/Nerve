# Nerve

[![MIT License](https://img.shields.io/badge/license-MIT-7c3aed.svg)](LICENSE)
[![Documentation](https://github.com/velumix/Nerve/actions/workflows/publish-docs.yml/badge.svg)](https://velumix.github.io/Nerve/)

Give your game a nervous system.

Nerve is a batteries-included Roblox framework with a service/controller
lifecycle, typed ByteNet networking, promises, signals, profile persistence,
cleanup utilities, components, input helpers, and common data utilities in one
drop-in package.

Nerve has no runtime dependencies outside its own folder.

## Documentation

Read the [Nerve documentation](https://velumix.github.io/Nerve/) for the
installation guide, lifecycle model, typed networking, schemas, bundled
dependencies, migration guide, and complete API reference.

## Install

Copy `src` into `ReplicatedStorage` as a ModuleScript named `Nerve`, or install
the package through Wally:

```toml
[dependencies]
Nerve = "velumix/nerve@1.0.0"
```

Server bootstrap:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Nerve = require(ReplicatedStorage.Nerve)

Nerve.AddServices(ServerScriptService.Services)
Nerve.Start():catch(warn)
```

Client bootstrap:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nerve = require(ReplicatedStorage.Nerve)

Nerve.AddControllers(ReplicatedStorage.Client.Controllers)
Nerve.Start():catch(warn)
```

## Typed networking

```luau
local Nerve = require(game:GetService("ReplicatedStorage").Nerve)
local S = Nerve.Schema

local InventoryService = Nerve.CreateService({
	Name = "InventoryService",
	Client = {},
	Network = {
		Equip = Nerve.Method({
			Request = S.Tuple({ S.String }),
			Response = S.Tuple({ S.Boolean, S.Optional(S.String) }),
			RateLimit = { Requests = 12, Window = 1 },
		}),
	},
})

function InventoryService.Client:Equip(player, itemId)
	return true, nil
end

return InventoryService
```

Nerve creates deterministic ByteNet packets from the service contract. Client
methods return cancellable promises and include timeouts, bounded in-flight
requests, server rate limits, and sanitized errors.

## Included dependencies

- ByteNet 0.4.6
- Promise 4.0.0
- Signal 2.0.3
- ProfileService 1.0.2
- Component 2.4.8
- Trove 1.8.0
- TableUtil 1.2.1
- Option 1.0.5
- Timer 2.0.0
- Input 3.0.0
- EnumList 2.1.0
- Streamable 1.2.4
- Symbol 2.0.1

Access a bundled utility without adding another package:

```luau
local ProfileService = Nerve.GetDependency("ProfileService")
local Trove = Nerve.GetDependency("Trove")
```

ProfileService is server-only in normal use. Dependencies are loaded lazily by
`GetDependency`; requiring Nerve does not initialize every bundled library.

## License

Nerve's original code is MIT licensed. Nerve is derived in part from Knit and
bundles third-party MIT and Apache-2.0 software. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and `licenses/`.

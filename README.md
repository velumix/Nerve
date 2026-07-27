# Nerve

[![MIT License](https://img.shields.io/badge/license-MIT-65a30d.svg)](LICENSE)
[![Documentation](https://github.com/velumix/Nerve/actions/workflows/publish-docs.yml/badge.svg)](https://velumix.github.io/Nerve/)

Give your game a nervous system.

Nerve is a batteries-included Roblox framework with a service/controller
lifecycle, typed ByteNet networking, React UI, promises, signals, profile
persistence, cleanup utilities, components, input helpers, and common data
utilities in one drop-in package.

Nerve has no runtime dependencies outside its own folder.

## Documentation

Read the [Nerve documentation](https://velumix.github.io/Nerve/) for the
installation guide, lifecycle model, typed networking, schemas, bundled
dependencies, migration guide, and complete API reference.

Framework contributors should also read [CONTRIBUTING.md](CONTRIBUTING.md) and
the [testing and validation guide](docs/testing.md).

## Install

Copy `src` into `ReplicatedStorage` as a ModuleScript named `Nerve`, or install
the package through Wally:

```toml
[dependencies]
Nerve = "velumix/nerve@1.3.0"
```

Nerve starts itself. Its bundled server and client Scripts run directly from the
Nerve package with `RunContext.Server` and `RunContext.Client`.

By default, the server loads direct ModuleScript children from
`ServerScriptService.Services`, and the client loads direct ModuleScript
children from `ReplicatedStorage.Client.Controllers`. If either folder is
absent, that realm starts with an empty registry.

Configure autostart with attributes on the Nerve ModuleScript:

- `AutoStart`, `AutoStartServer`, or `AutoStartClient` = `false` disables the
  matching bootstrap.
- `ServerServicesPath` and `ClientControllersPath` replace the default
  dot-separated DataModel paths.
- `DeepServiceDiscovery` and `DeepControllerDiscovery` enable recursive loading.

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
requests, default server rate limits, executable middleware, cancelled timeout
threads, and sanitized errors.

Lifecycle startup is supervised: `NerveInit` and `NerveStart` are Promise-owned,
and `Start()`/`OnStart()` reject with service or controller context when a hook
fails. Readiness is reported only after both phases complete.

## Included dependencies

- ByteNet 0.4.6
- Promise 4.0.0
- Signal 2.0.3
- ProfileStore 1.0.3
- ProfileService 1.0.2 (legacy compatibility)
- Component 2.4.8
- Trove 1.8.0
- TableUtil 1.2.1
- Option 1.0.5
- Timer 2.0.0
- Input 3.0.0
- EnumList 2.1.0
- Streamable 1.2.4
- Symbol 2.0.1
- React 17.3.10

Access a bundled utility without adding another package:

```luau
local ProfileStore = Nerve.GetDependency("ProfileStore")
local Trove = Nerve.GetDependency("Trove")
local React = Nerve.GetDependency("React")
```

ProfileStore is server-only. Dependencies are loaded lazily by
`GetDependency`; requiring Nerve does not initialize every bundled library.
ProfileService remains bundled only for backward compatibility and is no longer
recommended for new projects. See the
[ProfileStore guide](docs/profile-store.md) for session lifecycle and migration.
Use React from a client controller to build declarative UI in `PlayerGui`; see
the [React UI guide](docs/react-ui.md).

## License

Nerve's original code is MIT licensed. Nerve is derived in part from Knit and
bundles third-party MIT and Apache-2.0 software. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and `licenses/`.

---
sidebar_position: 1
sidebar_label: Start here
---

# Getting started

Nerve gives a Roblox game one predictable foundation for lifecycle, networking,
data, cleanup, components, input, and everyday utilities. Everything required
at runtime lives inside the package.

:::tip The short version
Drop Nerve into `ReplicatedStorage`, organize server services and client
controllers in the conventional folders, and declare every remote interaction
as a typed contract.
:::

## What ships together

| Layer | What Nerve provides |
| --- | --- |
| Lifecycle | Ordered service and controller initialization |
| Networking | Typed ByteNet methods and directional signals |
| Persistence | Bundled ProfileService for server-owned player data |
| Async and events | Promises and signals without extra packages |
| User interface | React and the Roblox renderer |
| Game structure | Components, cleanup, input, timers, and data utilities |
| Startup | Packaged server and client RunContext scripts |

Nerve has no runtime dependency outside its own folder. A project can move the
package between games without rebuilding a dependency tree.

## Install with Wally

Add Nerve to your `wally.toml`:

```toml
[dependencies]
Nerve = "velumix/nerve@1.2.0"
```

Run `wally install`, then map the package into `ReplicatedStorage` with Rojo:

```json
{
  "ReplicatedStorage": {
    "Packages": {
      "$path": "Packages"
    }
  }
}
```

Nerve is then available at
`ReplicatedStorage.Packages.Nerve`.

You can also copy the repository's `src` directory into `ReplicatedStorage` as a
ModuleScript named `Nerve`. No other runtime package is required.

## Create the conventional folders

Nerve starts with these locations by default:

```text
ReplicatedStorage
|-- Packages
|   `-- Nerve
`-- Client
    `-- Controllers

ServerScriptService
`-- Services
```

The folders may be empty while a project is being set up. Nerve still starts
successfully and freezes each registry after discovery.

## Automatic startup

Nerve includes two real Script instances inside its package:

- `ServerBootstrap` uses `RunContext.Server`.
- `ClientBootstrap` uses `RunContext.Client`.

Roblox runs them directly from `ReplicatedStorage.Packages.Nerve`, so no scripts
need to be created in `ServerScriptService` or `StarterPlayerScripts`.

The server loads direct ModuleScript children from
`ServerScriptService.Services`. The client loads direct ModuleScript children
from `ReplicatedStorage.Client.Controllers`. If a conventional folder does not
exist, Nerve still starts with an empty registry.

### Autostart attributes

Set these attributes on the Nerve ModuleScript when a game needs different
behavior:

| Attribute | Type | Effect |
| --- | --- | --- |
| `AutoStart` | boolean | Set `false` to disable both bootstraps. |
| `AutoStartServer` | boolean | Set `false` to disable server startup only. |
| `AutoStartClient` | boolean | Set `false` to disable client startup only. |
| `ServerServicesPath` | string | Dot-separated path from `game`; defaults to `ServerScriptService.Services`. |
| `ClientControllersPath` | string | Dot-separated path from `game`; defaults to `ReplicatedStorage.Client.Controllers`. |
| `DeepServiceDiscovery` | boolean | Recursively loads service ModuleScripts. |
| `DeepControllerDiscovery` | boolean | Recursively loads controller ModuleScripts. |

Nerve selects its server or client API automatically based on the current
runtime. See [Services and controllers](services-and-controllers.md) for the
lifecycle model, then [Typed networking](typed-networking.md) to expose your
first endpoint.

:::tip
Keep startup modules in the configured folders. The bundled bootstraps require
them before calling `Nerve.Start()`, then freeze the registries for deterministic
initialization.
:::

## Choose your next guide

| Goal | Guide |
| --- | --- |
| Create server and client systems | [Services and controllers](services-and-controllers.md) |
| Expose a typed method or signal | [Typed networking](typed-networking.md) |
| Describe network values precisely | [Schemas](schemas.md) |
| Use a bundled utility | [Bundled dependencies](bundled-dependencies.md) |
| Build declarative UI | [React UI](react-ui.md) |
| Move an existing Knit project | [Migrating from Knit](migration-from-knit.md) |

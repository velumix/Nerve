---
sidebar_position: 1
---

# Getting started

Nerve is a batteries-included Roblox framework. It gives your game a
service/controller lifecycle and a typed ByteNet networking layer while keeping
the package portable: everything required at runtime lives inside `Nerve`.

## Install with Wally

Add Nerve to your `wally.toml`:

```toml
[dependencies]
Nerve = "velumix/nerve@1.1.0"
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

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
Nerve = "velumix/nerve@1.0.0"
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

## Create the server bootstrap

```luau title="ServerScriptService/NerveServer.server.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Nerve = require(ReplicatedStorage.Packages.Nerve)

Nerve.AddServices(ServerScriptService.Services)
Nerve.Start():catch(warn)
```

## Create the client bootstrap

```luau title="StarterPlayerScripts/NerveClient.client.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nerve = require(ReplicatedStorage.Packages.Nerve)

Nerve.AddControllers(ReplicatedStorage.Client.Controllers)
Nerve.Start():catch(warn)
```

Nerve selects its server or client API automatically based on the current
runtime. See [Services and controllers](services-and-controllers.md) for the
lifecycle model, then [Typed networking](typed-networking.md) to expose your
first endpoint.

:::tip
Create every service or controller before calling `Nerve.Start()`. The
registries are frozen at startup to make initialization deterministic.
:::

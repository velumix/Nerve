---
sidebar_position: 5
sidebar_label: Bundled dependencies
---

# Bundled dependencies

Nerve is deliberately self-contained. Requiring Nerve does not initialize every
utility; bundled modules load lazily when requested.

:::tip
Use `Nerve.GetDependency(name)` instead of reaching into the package tree. It
keeps application code independent of Nerve's internal folder layout.
:::

```luau
local ProfileStore = Nerve.GetDependency("ProfileStore")
local Trove = Nerve.GetDependency("Trove")
local React = Nerve.GetDependency("React")
local ReactRoblox = Nerve.GetDependency("ReactRoblox")
```

The same modules are also present under `Nerve.Dependencies` for tooling that
needs the ModuleScript instance.

| Module | Version | Typical use |
| --- | ---: | --- |
| ByteNet | 0.4.6 | Typed, buffer-based networking |
| Promise | 4.0.0 | Asynchronous composition and cancellation |
| Signal | 2.0.3 | Local event dispatch |
| ProfileStore | 1.0.3 | Recommended server-side player data persistence |
| ProfileService | 1.0.2 | Legacy persistence compatibility |
| Component | 2.4.8 | Tag-driven component lifecycle |
| Trove | 1.8.0 | Resource cleanup |
| TableUtil | 1.2.1 | Common table operations |
| Option | 1.0.5 | Explicit optional values |
| Timer | 2.0.0 | Repeating timers |
| Input | 3.0.0 | Keyboard, mouse, touch, and gamepad helpers |
| EnumList | 2.1.0 | Custom enum-like values |
| Streamable | 1.2.4 | Streaming-aware instance access |
| Symbol | 2.0.1 | Unique symbolic keys |
| React | 17.3.10 | Declarative component and hook runtime |
| ReactRoblox | 17.3.10 | Roblox Instance renderer for React |

ProfileStore is server-only. Create the store with `ProfileStore.New`, start
player sessions with `StartSessionAsync`, and end them with `EndSession`.
ProfileService remains available for backward compatibility, but its upstream
project is no longer supported. Never trust persisted data sent back from the
client. See [ProfileStore](profile-store.md) for lifecycle and migration
guidance.

React and ReactRoblox are the maintained successors to legacy Roact. Mount UI
from a client controller so the Nerve lifecycle owns cleanup. See
[React UI](react-ui.md) for the complete pattern.

Nerve itself is MIT licensed. Bundled code remains under its original license;
see the repository's `THIRD_PARTY_NOTICES.md` and `licenses` directory for the
complete attribution.

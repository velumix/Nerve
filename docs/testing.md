---
sidebar_position: 7
sidebar_label: Testing and validation
---

# Testing and validation

Nerve keeps its framework tests in a dedicated Roblox Studio place. The test
project maps the real `src` package and disables packaged autostart so each
specification controls its own lifecycle boundary.

## Build the test place

Install the tools declared in `aftman.toml`, then run:

```powershell
rojo build test.project.json --output NerveTests.rbxlx
```

Open `NerveTests.rbxlx` in Roblox Studio and start a server session. The runner
loads every `*.spec.luau` module in name order. A successful run prints:

```text
[Nerve tests] Passed 2 specification(s)
```

The lifecycle suite currently verifies:

- name-ordered hook invocation;
- support for hooks that return Nerve promises;
- contextual rejection when a hook fails;
- service lookup during `NerveInit`;
- the boundary between `NerveInit`, `NerveStart`, and readiness; and
- `OnStart()` calls registered before startup.

## Validate a contribution

Before opening or updating a pull request, run:

```powershell
stylua --check src/*.luau tests/*.luau
selene src/Lifecycle.luau src/NerveServer.luau src/NerveClient.luau tests
rojo build default.project.json --output Nerve.rbxm
rojo build test.project.json --output NerveTests.rbxlx
npm ci
npm run docs:build
```

Generated `.rbxm` and `.rbxlx` files are ignored by Git. Vendored dependencies
are not reformatted or rewritten as part of a framework contribution.

## Add a specification

Create a ModuleScript ending in `.spec.luau` under `tests` and return one test
function. Throw or assert on failure; the runner reports the specification name
and reason.

Keep pure behavior in focused specifications. Use the startup integration
specification only for behavior that depends on the real Nerve server module.

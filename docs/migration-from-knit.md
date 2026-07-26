---
sidebar_position: 6
---

# Migrating from Knit

Nerve preserves the familiar service/controller lifecycle while replacing
Knit's remote layer with typed ByteNet contracts.

## Rename the framework surface

| Knit | Nerve |
| --- | --- |
| `Knit.CreateService` | `Nerve.CreateService` |
| `Knit.CreateController` | `Nerve.CreateController` |
| `KnitInit` | `NerveInit` |
| `KnitStart` | `NerveStart` |
| `Knit.Start` | `Nerve.Start` |

Rename bootstrap scripts and local variables as well, then ensure every service
and controller loads before `Nerve.Start()`.

## Replace implicit remotes

Move remotely exposed members into an explicit `Network` contract:

```luau
local S = Nerve.Schema

local ExampleService = Nerve.CreateService({
	Name = "ExampleService",
	Client = {
		MessageChanged = Nerve.Signal(S.Tuple({ S.String })),
	},
	Network = {
		GetMessage = Nerve.Method({
			Request = S.Tuple({}),
			Response = S.Tuple({ S.String }),
		}),
	},
})

function ExampleService.Client:GetMessage(_player)
	return "Hello from Nerve"
end
```

Client methods now return promises and can fail with `TIMEOUT`, `OVERLOADED`,
`RATE_LIMITED`, or `SERVER_ERROR`. Handle rejections with `:catch(...)`.

For a mechanical checklist and compatibility notes, see
[`MIGRATION.md`](https://github.com/velumix/Nerve/blob/main/MIGRATION.md).

# Migrating from Knit

Nerve keeps the familiar service/controller lifecycle while replacing Comm
with a typed ByteNet transport and bundling its runtime dependencies.

## Rename imports

```luau
-- Before
local Knit = require(ReplicatedStorage.Packages.Knit)

-- After
local Nerve = require(ReplicatedStorage.Nerve)
```

Rename `Knit` variables and calls to `Nerve`. Service and controller lifecycle
methods retain their familiar names.

## Declare network contracts

Remote methods should be declared under the service's `Network` table:

```luau
Network = {
	GetValue = Nerve.Method({
		Request = Nerve.Schema.Tuple({ Nerve.Schema.String }),
		Response = Nerve.Schema.Tuple({ Nerve.Schema.Unknown }),
	}),
}
```

Signals use `Nerve.CreateSignal` or `Nerve.CreateUnreliableSignal`.

## Replace external packages

Use `Nerve.GetDependency("Promise")`, `Nerve.GetDependency("Signal")`,
`Nerve.GetDependency("ProfileService")`, or another included dependency.

## Intentional differences

- ByteNet is the only remote transport.
- Client remote methods always return promises.
- Network calls use schemas, timeouts, bounded concurrency, and optional
  server-side rate limits.
- Comm middleware and remote properties are not part of Nerve 1.0.
- Nerve does not destroy or mutate its own package tree at runtime.

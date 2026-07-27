---
sidebar_position: 4
sidebar_label: Schemas
---

# Schemas

`Nerve.Schema` describes the values carried by methods and signals. Descriptors
are immutable plain tables so Nerve can serialize them into its network
manifest.

## Primitive descriptors

| Descriptor | Luau value |
| --- | --- |
| `Boolean` | `boolean` |
| `String` | `string` |
| `Buffer` | `buffer` |
| `UInt8`, `UInt16`, `UInt32` | unsigned integer |
| `Int8`, `Int16`, `Int32` | signed integer |
| `Float32`, `Float64` | number |
| `Vector2`, `Vector3` | Roblox vector |
| `CFrame` | `CFrame` |
| `Color3` | `Color3` |
| `Instance` | `Instance` |
| `Nothing` | no value |
| `Unknown` | dynamically encoded supported value |
| `Packed` | dynamically encoded tuple; useful while migrating |

Choose the narrowest safe numeric descriptor. For example, an ammo count that
cannot exceed 255 fits `UInt8`, while world coordinates normally need a float
or vector descriptor.

## Composing descriptors

```luau
local S = Nerve.Schema

local Item = S.Struct({
	Id = S.String,
	Quantity = S.UInt16,
	Equipped = S.Boolean,
	Metadata = S.Optional(S.Map(S.String, S.String)),
})

local InventoryResponse = S.Tuple({
	S.Array(Item),
	S.Optional(S.String),
})
```

- `Optional(value)` allows a value to be absent.
- `Array(value)` describes a dense array.
- `Map(key, value)` describes a key/value map.
- `Struct(fields)` describes a string-keyed record.
- `Tuple(items)` describes ordered arguments or return values.

Use `Schema.Validate(descriptor)` in tooling or tests when constructing schemas
dynamically. `Nerve.Method` and `Nerve.Signal` validate their descriptors
automatically.

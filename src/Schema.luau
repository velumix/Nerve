--!strict

--[[
	Schema descriptors are deliberately plain tables. The server serializes them
	into the Nerve network manifest, and the client reconstructs identical ByteNet
	data types without requiring server-only service modules.
]]

export type Descriptor = {
	kind: string,
	[any]: any,
}

local Schema = {}

local function primitive(kind: string): Descriptor
	return table.freeze({ kind = kind })
end

Schema.Packed = primitive("packed")
Schema.Nothing = primitive("nothing")
Schema.Unknown = primitive("unknown")
Schema.Boolean = primitive("bool")
Schema.String = primitive("string")
Schema.Buffer = primitive("buffer")
Schema.UInt8 = primitive("uint8")
Schema.UInt16 = primitive("uint16")
Schema.UInt32 = primitive("uint32")
Schema.Int8 = primitive("int8")
Schema.Int16 = primitive("int16")
Schema.Int32 = primitive("int32")
Schema.Float32 = primitive("float32")
Schema.Float64 = primitive("float64")
Schema.Vector2 = primitive("vec2")
Schema.Vector3 = primitive("vec3")
Schema.CFrame = primitive("cframe")
Schema.Color3 = primitive("color3")
Schema.Instance = primitive("instance")

local primitives = table.freeze({
	packed = true,
	nothing = true,
	unknown = true,
	bool = true,
	string = true,
	buffer = true,
	uint8 = true,
	uint16 = true,
	uint32 = true,
	int8 = true,
	int16 = true,
	int32 = true,
	float32 = true,
	float64 = true,
	vec2 = true,
	vec3 = true,
	cframe = true,
	color3 = true,
	instance = true,
})

local function assertDescriptor(value: any, label: string): Descriptor
	assert(type(value) == "table" and type(value.kind) == "string", `{label} must be a Nerve schema descriptor`)
	return value
end

function Schema.Optional(value: Descriptor): Descriptor
	return table.freeze({
		kind = "optional",
		value = assertDescriptor(value, "optional value"),
	})
end

function Schema.Array(value: Descriptor): Descriptor
	return table.freeze({
		kind = "array",
		value = assertDescriptor(value, "array value"),
	})
end

function Schema.Map(key: Descriptor, value: Descriptor): Descriptor
	return table.freeze({
		kind = "map",
		key = assertDescriptor(key, "map key"),
		value = assertDescriptor(value, "map value"),
	})
end

function Schema.Struct(fields: { [string]: Descriptor }): Descriptor
	assert(type(fields) == "table", "struct fields must be a table")
	local copy = {}
	for name, descriptor in fields do
		assert(type(name) == "string" and #name > 0, "struct field names must be non-empty strings")
		copy[name] = assertDescriptor(descriptor, `struct field {name}`)
	end
	return table.freeze({
		kind = "struct",
		fields = table.freeze(copy),
	})
end

function Schema.Tuple(items: { Descriptor }): Descriptor
	assert(type(items) == "table", "tuple items must be an array")
	local copy = {}
	for index, descriptor in items do
		assert(type(index) == "number" and index % 1 == 0 and index >= 1, "tuple items must be a dense array")
		copy[index] = assertDescriptor(descriptor, `tuple item {index}`)
	end
	assert(#copy == #items, "tuple items must be a dense array")
	return table.freeze({
		kind = "tuple",
		items = table.freeze(copy),
	})
end

function Schema.Validate(descriptor: Descriptor, path: string?): ()
	local currentPath = path or "schema"
	assertDescriptor(descriptor, currentPath)
	local kind = descriptor.kind
	if primitives[kind] then
		return
	end
	if kind == "optional" or kind == "array" then
		Schema.Validate(descriptor.value, `{currentPath}.value`)
		return
	end
	if kind == "map" then
		Schema.Validate(descriptor.key, `{currentPath}.key`)
		Schema.Validate(descriptor.value, `{currentPath}.value`)
		return
	end
	if kind == "struct" then
		assert(type(descriptor.fields) == "table", `{currentPath}.fields must be a table`)
		for name, value in descriptor.fields do
			assert(type(name) == "string", `{currentPath} contains a non-string field name`)
			Schema.Validate(value, `{currentPath}.{name}`)
		end
		return
	end
	if kind == "tuple" then
		assert(type(descriptor.items) == "table", `{currentPath}.items must be an array`)
		for index, value in descriptor.items do
			Schema.Validate(value, `{currentPath}[{index}]`)
		end
		return
	end
	error(`Unsupported Nerve schema kind "{tostring(kind)}" at {currentPath}`, 2)
end

return table.freeze(Schema)

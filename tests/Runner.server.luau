--!strict

local specifications = {}

for _, child in script.Parent:GetChildren() do
	if child:IsA("ModuleScript") and string.match(child.Name, "%.spec$") then
		table.insert(specifications, child)
	end
end

table.sort(specifications, function(left, right)
	return left.Name < right.Name
end)

local failures = {}

for _, specification in specifications do
	local loaded, testOrReason = pcall(require, specification)
	if not loaded then
		table.insert(failures, `{specification.Name} failed to load: {tostring(testOrReason)}`)
		continue
	end

	local passed, reason = pcall(testOrReason)
	if not passed then
		table.insert(failures, `{specification.Name} failed: {tostring(reason)}`)
	end
end

if #failures > 0 then
	error(`[Nerve tests]\n{table.concat(failures, "\n")}`)
end

print(`[Nerve tests] Passed {#specifications} specification(s)`)

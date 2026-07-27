# Nerve tests

Build the dedicated Studio test place:

```powershell
rojo build test.project.json --output NerveTests.rbxlx
```

Open `NerveTests.rbxlx` in Roblox Studio and start a server session. The
`Runner` script executes every `*.spec.luau` module in name order. A successful
run prints:

```text
[Nerve tests] Passed 5 specification(s)
```

The test project disables Nerve's packaged autostart so the startup integration
spec can control the lifecycle boundary itself.

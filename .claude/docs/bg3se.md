# BG3 Script Extender (bg3se) Reference

Source: `bg3se/` — cloned from the official bg3se repository. Do not modify.

## API Reference

Full API documentation (Lua API v22): [`bg3se/Docs/API.md`](../../bg3se/Docs/API.md)

Covers: Bootstrap Scripts, Client/Server states, Osiris↔Lua interop, Stats, ECS, Networking, and more.

## Overview

bg3se adds a Lua scripting layer to Baldur's Gate 3, exposing game internals via the `Ext` API.

## Key Directories in bg3se

| Path | Purpose |
|------|---------|
| `bg3se/BG3Extender/` | Core extender source (C++) |
| `bg3se/LuaLib/` | Built-in Lua libraries exposed to mods |
| `bg3se/Docs/` | Official documentation |
| `bg3se/SampleMod/` | Example mod using bg3se features |

## Lua Entry Points

Mods using bg3se place Lua files under `Scripts/` in the mod folder.
Common bootstrap file: `Scripts/BootstrapServer.lua` (server-side) / `Scripts/BootstrapClient.lua` (client-side).

## Common Ext APIs

```lua
-- Listen to game events
Ext.Events.<EventName>:Subscribe(function(e) ... end)

-- Get an entity/character by UUID
local entity = Ext.Entity.Get(uuid)

-- Logging
Ext.Utils.Print("message")
```

## Notes

- Add specific API patterns, gotchas, and version notes here as you work with bg3se.

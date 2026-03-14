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

## Important API Distinctions

### `Osi.GetHostCharacter()` — returns the **host player's created character** (Tav/Dark Urge)
- This is an Osiris query (server-side). It does **NOT** change when you switch selected party member.
- `_C()` is a console shorthand for `Ext.Entity.Get(Osi.GetHostCharacter())`.
- Source: `bg3se/BG3Extender/LuaScripts/BuiltinLibraryServer.lua:52`

### `ClientControl` component — marks the **currently selected/controlled character** (client-side)
- Defined as a tag component (no data fields): `DEFINE_TAG_COMPONENT(eoc, ClientControlComponent, ClientControl)`
- Source: `bg3se/BG3Extender/GameDefinitions/Components/Data.h:215`
- Use `Ext.Entity.GetAllEntitiesWithComponent("ClientControl")` on the **client** to find the selected character.
- This is client-only — server-side code needs a net message bridge to receive the selected character UUID.

### Client→Server selected character pattern
```lua
-- BootstrapClient.lua: track selection and notify server
local lastSelected = nil
Ext.Events.Tick:Subscribe(function()
    local selected = nil
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
        if entity.Uuid then
            selected = tostring(entity.Uuid.EntityUuid)
            break
        end
    end
    if selected and selected ~= lastSelected then
        lastSelected = selected
        Ext.Net.PostMessageToServer('MyMod_SelectedChar', selected)
    end
end)

-- Server-side: receive and use
local selectedChar = nil
Ext.RegisterNetListener('MyMod_SelectedChar', function(_, payload)
    selectedChar = payload
end)
```

### Stat functor context targets (`OnDamaged`, `OnAttack`, etc.)
| Context | `context.Source` | `context.Target` |
|---|---|---|
| `OnDamaged` | Attacker (dealt damage) | Passive owner (took damage) |
| `OnAttack` | Passive owner (attacker) | Attack target |
| `OnCastResolved` | Passive owner (caster) | Spell target |

### `SG_` status groups
- `SG_Stunned`, `SG_Charmed`, etc. are status **groups**, not individual statuses.
- Valid in: `StatusImmunity(SG_Stunned)`, `HasStatus('SG_Charmed')` in KHN conditions
- **Invalid in**: `ApplyStatus(SG_Charmed)` — use specific status IDs like `CHARMED`, `STUNNED`

## Notes

- Add specific API patterns, gotchas, and version notes here as you work with bg3se.

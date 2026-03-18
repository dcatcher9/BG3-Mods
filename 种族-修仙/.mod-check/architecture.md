# Architecture — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Mod Identity
- **Mod folder**: XIUXIAN
- **ModuleUUID**: aa2e0d85-aed6-4125-a16c-ecfc846ee744
- **Display name**: 种族-修仙
- **Author**: DCatcher
- **Type**: Universal mod (grants system to all characters via Lua, no subrace)

## Resource UUIDs
- QiPoint: 99465841-c763-4f1f-b025-02af228116b0 (LongRest)
- ShenshiPoint: 469d454d-8778-4412-a8b4-49c6becbe18e (ShortRest)

## File Tree

### LSX (2 files)
- `Mods/XIUXIAN/meta.lsx` — mod metadata
- `Public/XIUXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx` — QiPoint + ShenshiPoint

### Stats (2 files)
- `Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_BASE.txt` — XIUXIAN_Racial_Passive
- `Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_LINGGEN.txt` — 5 LingGen statuses + base template

### Lua (8 files)
- `ScriptExtender/Lua/BootstrapServer.lua` — PersistentVars + require Main
- `ScriptExtender/Lua/BootstrapClient.lua` — empty stub
- `ScriptExtender/Lua/Server/Main.lua` — module loader (LingGen, Debug)
- `ScriptExtender/Lua/Server/Modules/Variables.lua` — constants
- `ScriptExtender/Lua/Server/Modules/Utils.lua` — utilities + GrantXiuXian
- `ScriptExtender/Lua/Server/Modules/EventHandlers.lua` — event routing
- `ScriptExtender/Lua/Server/Modules/Systems/Debug.lua` — console commands
- `ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua` — spiritual root system

### Localization (1 file)
- `Mods/XIUXIAN/Localization/English/XIUXIAN.xml` — 10 content entries

### Config (1 file)
- `ScriptExtender/Config.json` — RequiredVersion 14, Osiris+Lua

### Icons (6 DDS files)
- `Public/Game/GUI/Assets/ActionResources_c/Icons/QiPoint.DDS`
- `Public/Game/GUI/Assets/ActionResources_c/Icons/ShenshiPoint.DDS`
- `Public/Game/GUI/Assets/CC/icons_resources/QiPoint.DDS`
- `Public/Game/GUI/Assets/CC/icons_resources/ShenshiPoint.DDS`
- `Public/Game/GUI/Assets/Shared/Resources/QiPoint.DDS`
- `Public/Game/GUI/Assets/Shared/Resources/ShenshiPoint.DDS`

## Naming Conventions
- Stat prefix: `XIUXIAN_`
- Loca handle prefix: `hXIUXIAN_`
- LingGen status prefix: `XIUXIAN_LG_`

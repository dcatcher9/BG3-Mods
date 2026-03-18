# Architecture — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Mod Identity
- **Mod folder**: XIUXIAN
- **ModuleUUID**: aa2e0d85-aed6-4125-a16c-ecfc846ee744
- **Display name**: 种族-修仙
- **Author**: DCatcher
- **Type**: Human subrace (ParentGuid = 0eb594cb-8820-4be6-a58d-8be7a1a98fba)
- **Race UUID**: 95ee3322-742a-4c06-8946-1f47f0ec10c7
- **Progression Table UUID**: 4c410729-21d2-43b6-89e2-0e09a026ba8d
- **Tag UUID**: e600bc79-6e7d-41cb-b90f-dc6f8fef63ee

## Resource UUIDs
- QiPoint: 99465841-c763-4f1f-b025-02af228116b0 (LongRest)
- ShenshiPoint: 469d454d-8778-4412-a8b4-49c6becbe18e (ShortRest)

## File Tree

### LSX (8 files)
- `Mods/XIUXIAN/meta.lsx` — mod metadata
- `Public/XIUXIAN/Races/Races.lsx` — subrace definition
- `Public/XIUXIAN/Tags/e600bc79-...lsx` — XIUXIAN tag
- `Public/XIUXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx` — QiPoint + ShenshiPoint
- `Public/XIUXIAN/Progressions/Progressions.lsx` — L1 progression
- `Public/XIUXIAN/Progressions/ProgressionDescriptions.lsx` — empty stub
- `Public/XIUXIAN/Lists/SpellLists.lsx` — empty stub
- `Public/XIUXIAN/Lists/PassiveLists.lsx` — empty stub

### Stats (1 file)
- `Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_BASE.txt` — XIUXIAN_Racial_Passive

### Lua (7 files)
- `ScriptExtender/Lua/BootstrapServer.lua` — PersistentVars + require Main
- `ScriptExtender/Lua/BootstrapClient.lua` — empty stub
- `ScriptExtender/Lua/Server/Main.lua` — module loader
- `ScriptExtender/Lua/Server/Modules/Variables.lua` — constants
- `ScriptExtender/Lua/Server/Modules/Utils.lua` — utilities
- `ScriptExtender/Lua/Server/Modules/EventHandlers.lua` — event routing
- `ScriptExtender/Lua/Server/Modules/Systems/Debug.lua` — console commands

### Localization (1 file)
- `Mods/XIUXIAN/Localization/English/XIUXIAN.xml` — 8 content entries

### Config (1 file)
- `ScriptExtender/Config.json` — RequiredVersion 14, Osiris+Lua

## Naming Conventions
- Stat prefix: `XIUXIAN_`
- Loca handle prefix: `hXIUXIAN_`
- PersistentVars key prefix: `XIUXIANLIST_`

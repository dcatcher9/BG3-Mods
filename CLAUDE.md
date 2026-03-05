# BG3 Mods — Claude Code Project Instructions

## Repository Structure

```
BG3 Mods/
├── CLAUDE.md                   ← You are here (auto-loaded by Claude Code)
├── .claude/
│   ├── docs/                   ← Shared reference docs across all mods
│   └── skills/                 ← Project-level slash commands (one folder per skill)
│       ├── bg3se.md            ← Script Extender API notes & patterns
│       └── mods-overview.md    ← Mod list, purpose, and cross-mod notes
├── bg3se/                      ← Cloned BG3 Script Extender (read-only reference)
├── 主职-灭法之影2.6/           ← Mod: Class - Shadow of Spellbreaker 2.6
└── 种族-谪仙[三仙归人]/        ← Mod: Race - Exiled Immortal [Three Immortals]
```

## Shared Docs

All shared reference material lives in [`.claude/docs/`](.claude/docs/):
- [bg3se.md](.claude/docs/bg3se.md) — Script Extender usage, Lua API, patterns
- [mods-overview.md](.claude/docs/mods-overview.md) — Per-mod notes and cross-mod context

## Key Conventions

- Mods follow the standard BG3 mod layout: `Mods/` (metadata) + `Public/` (assets/data)
- `bg3se` is a reference clone — do not modify it
- Lua scripts (if any) live under `Scripts/` inside the mod folder
- Chinese folder/file names are intentional — do not rename them

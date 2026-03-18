# Patterns & Design Decisions — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Coding Patterns
- Module loader pattern: Main.lua creates table, requires systems, calls Init(), then loads EventHandlers
- PersistentVars indexed list: `XIUXIANLIST_NO_1`, `XIUXIANLIST_NO_2`, etc. (matches reference mod pattern)
- SavegameLoaded → timer → restore data (3000ms delay for engine readiness)

## Intentional Design
- **Empty stub files** (SpellLists, PassiveLists, ProgressionDescriptions): Placeholder for future phases. Not redundancy.
- **BootstrapClient.lua is empty**: Client-side modules will be added in Phase 3 (ImGui).

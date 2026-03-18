# Patterns & Design Decisions — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Coding Patterns
- Module loader pattern: Main.lua creates table, requires systems, calls Init(), then loads EventHandlers
- Dependency injection: Main.lua injects `Utils._Systems = Systems` after init, so Osiris callbacks can access modules without require()
- SavegameLoaded → timer (3000ms) → ScanParty (engine readiness delay)
- LingGen stored as status turns (value * 6) — auto-persists with saves for all entities
- GrantXiuXian is idempotent — checks HasPassive for resource grant, Awake has its own guard
- IsRealCharacter filter — excludes Dummy/Helper/Invisible/Intangible template names
- Debug console command: `!xx` (short prefix)
- GetDisplayName: tries entity.DisplayName.NameKey → Ext.Loca.GetTranslatedString, falls back to GUID
- GetFactionTag: IsAlly→[友], IsEnemy→[敌], else→[中]

## Intentional Design (do not re-flag)
- **Empty BootstrapClient.lua**: Client-side modules will be added in Phase 3 (ImGui)
- **Passive has no Boosts**: Resources granted via Osi.AddBoosts in Lua, not stat Boosts field. Avoids double-grant.
- **All real characters get system**: Enemies get passive + LingGen on combat enter. By design.
- **awakeGuard local table grows unbounded**: One string key per awakened entity — negligible memory. Resets on reload, status-turns check is the durable guard.
- **LingGen.Awake outside idempotency guard**: Must run even if passive already exists (for characters from older saves). Awake has its own internal idempotency (GetTotal > 0 + awakeGuard).

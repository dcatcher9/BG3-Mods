# Features — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Feature Table

| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|
| Auto-grant system | Full | Automatic (all chars) | Utils.lua GrantXiuXian, EventHandlers.lua |
| Qi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, Utils.lua |
| ShenShi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, Utils.lua |
| Racial Passive (修行之体) | Full | Passive | XIUXIAN_BASE.txt |
| LingGen (灵根) | Full | Console (!xiuxian linggen) | LingGen.lua, XIUXIAN_LINGGEN.txt, Variables.lua |
| Debug Console | Full | Console (!xiuxian) | Debug.lua |

## Feature Details

### Auto-grant System
**What**: Automatically grants cultivation passive + resources + LingGen to all characters
**Chain**: EventHandlers (SavegameLoaded/EnteredCombat/CharacterJoinedParty/LeveledUp) → Utils.GrantXiuXian → AddPassive + AddBoosts + LingGen.Awake
**Access**: Automatic — party on load, enemies on combat enter
**Completeness**: Full

### LingGen (灵根)
**What**: 5-element spiritual root values stored as status turns, randomly initialized
**Chain**: Utils.GrantXiuXian → LingGen.Awake (random roll) → Osi.ApplyStatus (XIUXIAN_LG_MU/HUO/TU/JIN/SHUI)
**Access**: Console (`!xiuxian linggen`, `!xiuxian scan`, `!xiuxian setlg`)
**Completeness**: Full — init, read, write, tier calculation, debug display
**Notes**: Distribution: 1% godly(200), 4% excellent(100), 10% good(50), 25% average(25), 60% weak(10). Values * 6 for status turns.

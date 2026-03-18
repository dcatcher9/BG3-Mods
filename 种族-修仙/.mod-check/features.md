# Features — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Feature Table

| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|
| Subrace (修仙) | Full | Character Creation | Races.lsx, Progressions.lsx |
| Qi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, Progressions.lsx |
| ShenShi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, Progressions.lsx |
| Racial Passive (修行之体) | Full | Passive | XIUXIAN_BASE.txt |
| Debug Console | Full | Console (!xiuxian) | Debug.lua |
| Meridian Graph | Stub | N/A | Variables.lua (constants only) |
| Walk Engine | Stub | N/A | Utils.lua (EdgeDistance only) |

## Feature Details

### Subrace
**What**: Human subrace "修仙" selectable in character creation
**Chain**: Races.lsx → Progressions.lsx → grants passive + resources
**Access**: Character Creation
**Completeness**: Full

### Resources (Qi + ShenShi)
**What**: Two custom action resources for the cultivation system
**Chain**: ActionResourceDefinitions.lsx defines them → Progressions.lsx Boosts grant initial amounts
**Access**: Action bar resource display
**Completeness**: Full

### Debug Console
**What**: Console commands for inspecting mod state
**Chain**: Debug.lua registers `!xiuxian` console command
**Access**: SE console
**Completeness**: Full — supports `debug`, `info`, `distance` subcommands

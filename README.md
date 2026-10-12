# MoonRange 🌙 — v0.1 beta

Opulent-style overhead nameplates for WoW Forever.

## Setup
Place the MoonRange folder in your WoW client's Interface/AddOns folder. Download/copy the **five TGA textures** supplied separately into MoonRange/Textures/: BG_Moon.tga, Fill_Moon.tga, Frame_Moon.tga, Frame_Moon_Light.tga, Frame_NoMoon.tga.

## Commands
- /moonrange — config
- /mr spell Arcane Blast — choose any spell from your current character's spellbook
- /mr debug — diagnose class and range checking
- /mr on or /mr off — enable or disable

Settings are saved per character. The addon automatically reads your class and known spells.

## Beta limitations
Nameplate access on Forever is **not yet verified in-game**. The current prototype recognises NamePlate* WorldFrame children and requires an exposed target unit token before it shows the moon. If Forever does not provide these structures, the addon needs a client-specific adapter; the current code deliberately refuses to guess which enemy is targeted. The visuals also need in-game alignment testing.

The original binary TGA files are included in the local full build; GitHub's text-only file write integration cannot directly transfer the existing uploaded binaries.

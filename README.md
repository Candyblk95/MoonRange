# MoonRange 🌙

**Enchanted, spell-aware nameplates for World of Warcraft: Forever (1.60.1)**  
*NamePlater made by Candy Black*

MoonRange gives Blizzard's overhead unit nameplates a magical makeover. Inspired by moonlit Night Elf aesthetics, it adds ornate frames and custom colours while keeping the underlying Blizzard nameplate health and cast bars in place.

## ✨ What MoonRange does

- **Two visual themes:** **Moon** (blue, moonlit fantasy) and **Herbalism** (nature-inspired).
- **Spell-based range feedback:** choose a known spell from your character's spellbook. MoonRange checks its range using the WoW client API `C_Spell.IsSpellInRange` and changes the nameplate's visual range indication. Range behaviour depends on what the client API can determine about the unit.
- **Custom nameplate presentation:** adjust name and level font sizes and positions.
- **Blizzard cast-bar positioning:** adjust the size and placement of the cast bar displayed with nameplates without replacing its underlying Blizzard functionality.
- **Live preview:** experiment with theme, fonts, and friendly/hostile preview targets from the settings window.
- **Per-character settings:** each character keeps their own spell choice, theme, and layout.

MoonRange is a **nameplate addon**, not a player casting-bar replacement. It is designed to complement, rather than compete with, a dedicated casting-bar addon.

## 🌙 Designed to pair with Opulent Casting Bars

MoonRange was designed with **[Opulent Casting Bars by SimonPdv](https://www.curseforge.com/wow/addons/opulent-casting-bars)** in mind.

**Opulent Casting Bars** provides richly animated, spell-school-themed casting bars for the player's casting experience. **MoonRange** focuses on overhead unit nameplates and range-aware visuals. Together they can create a consistent, magical UI without MoonRange attempting to replace Opulent Casting Bars.

**Credit and thanks to SimonPdv**, creator of Opulent Casting Bars, for the inspiration and beautiful fantasy UI aesthetic. Opulent Casting Bars is a separate addon by its own author; MoonRange is an independent project, not an official extension or endorsement.

Opulent Casting Bars is **optional**, not a dependency. Both addons can be used independently.

## ⚙️ Installation

1. Download the MoonRange addon from this repository.
2. Put the **MoonRange** folder in your WoW Forever installation's `Interface/AddOns/` directory.
3. Make sure the included `Textures/` directory and its TGA artwork are kept inside the addon folder.
4. Enable MoonRange from the in-game AddOns menu, then enter the world.
5. Open the MoonRange settings window using `/moonrange` (or `/moonr` if supported by your installed build).

## 🎨 Settings

The MoonRange configuration window has three pages:

| Page | What it controls |
| --- | --- |
| **Nameplates** | Theme, font, live preview, name and level placement, and Blizzard nameplate cast-bar sizing and positioning |
| **Spells** | Choose which known spell determines your range indicator |
| **Profiles** | View the current character's settings; settings are saved separately per character |

Select the spell you actually want to measure range against. For example, different classes and spells can have different effective ranges.

## 🐛 Bug reports and support

**[🌙 Open the MoonRange Bug Report Portal](https://candyblk95.github.io/MoonRange/bug-portal/)**

If you encounter a Blizzard Lua error:

1. Copy the full error text and stack trace.
2. Open the Bug Report Portal and paste the error.
3. Add your MoonRange version, selected theme, and steps to reproduce the problem.
4. Select **Prepare GitHub bug report** and submit the issue on GitHub.

You can also [view existing issues or report a bug directly](https://github.com/Candyblk95/MoonRange/issues).

The portal prepares a GitHub issue; it does **not** automatically modify your addon files or push unreviewed code. GitHub sign-in is required to submit an issue. Please remove any personal information from logs before posting them publicly.

## 🔧 Development notes

- Target client: **WoW Forever 1.60.1**.
- Range checks use **`C_Spell.IsSpellInRange`**.
- MoonRange preserves Blizzard's underlying nameplate health and cast bars, rather than replacing the cast-bar implementation.
- The addon is actively evolving; please report compatibility issues with full Lua errors and reproduction steps.

## 💙 Credits

**MoonRange** — created by **Candy Black**.  
**[Opulent Casting Bars](https://www.curseforge.com/wow/addons/opulent-casting-bars)** — created by **SimonPdv**; inspiration for the complementary fantasy casting-bar aesthetic.

---

*Walk beneath Elune's light.* 🌙

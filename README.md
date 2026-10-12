<div align="center">

# ☾ ✧ M O O N R A N G E ✧ ☽

### 𓆩 ✦ A little moonlight for your nameplates ✦ 𓆪

**A cute, spell-based range detection addon for WoW Forever**  
*Made with love, a little magic, and probably too much pink by Candy Black* 💗

🎯 **Know when you're in range** · 🌙 **Moonlit magic** · 🌿 **Herbal enchantments**

[**✧ Report a Bug ✧**](https://candyblk95.github.io/MoonRange/bug-portal/) · [**✧ Download the Addon ✧**](https://github.com/Candyblk95/MoonRange) · [**✧ GitHub Issues ✧**](https://github.com/Candyblk95/MoonRange/issues)

<sub>❝ Elune light your path, darling. ❞</sub>

</div>

---

## 🎯 First and foremost: a cute little range detector!

Ever been standing there, looking *adorable*, wondering whether your spell will actually reach that mob? Same, darling. 💗

**MoonRange was created primarily to make spell range detection cute, clear, and easy to see.** That's the whole heart of the addon. The pretty nameplates are there to make that range feedback feel magical — not to turn MoonRange into a complicated nameplate replacement.

### ✨ How the range magic works

1. **Pick a spell** from your character's spellbook in MoonRange's **Spells** settings.
2. **Target an enemy** with a supported nameplate.
3. **Watch the visual range indicator** on its nameplate respond to whether your chosen spell can reach it.
4. **Move into range** and cast away, moon child! 🌙

MoonRange checks the selected spell using **`C_Spell.IsSpellInRange`**. It follows the spell you choose, so the range being checked is relevant to *your class, your spell, and your character*.

> 💙 **The important bit:** MoonRange's **main feature is range detection**. The artwork, themes, and nameplate customisation are the cute packaging around that one job.

### 🌸 A little extra sparkle

| ✧ | Feature | What it does |
|:--:|---|---|
| 🎯 | **Spell-based range detection** | The star of the show! Visual feedback based on the range of a spell you choose. |
| 📖 | **Your own spellbook** | Select a spell your character actually knows instead of relying on a one-size-fits-all distance. |
| 🌙 | **Moon theme** | Dress your range indicator in dreamy, moonlit fantasy artwork. |
| 🌿 | **Herbalism theme** | A nature-inspired alternative, including Candy's extra Herbalism range icon. |
| 🔮 | **Live preview** | See how your nameplates look while you adjust them. |
| 🖋️ | **Optional customisation** | Fine-tune names, levels, fonts, and the placement of native Blizzard nameplate cast bars. |
| 🦋 | **Per-character settings** | Your hunter, mage, and druid can each use their own spell and look. |

<sub>Range checks depend on the client returning a valid result for the chosen spell and unit. MoonRange doesn't promise range information when the API can't determine it.</sub>

---

## 💜 Made to pair with Opulent Casting Bars

<div align="center">

### ✧ Two addons. One enchanted aesthetic. ✧

**[🌟 Opulent Casting Bars — by SimonPdv](https://www.curseforge.com/wow/addons/opulent-casting-bars)**

</div>

MoonRange is **first and foremost a range detection addon**. Its decorative nameplates were designed with **Opulent Casting Bars** in mind, because a useful range indicator can be pretty too!

- **Opulent Casting Bars** handles its own magical casting-bar experience.
- **MoonRange** focuses on **spell-based range detection**, displayed through pretty overhead nameplate visuals.
- MoonRange keeps the **native Blizzard nameplate health and cast bars** rather than replacing their underlying behaviour.

**Artwork credit:** The original nameplate artwork and visual assets used by MoonRange belong to **SimonPdv, creator of Opulent Casting Bars**. Candy Black adapted the artwork for MoonRange and added extra elements, including the **custom configuration GUI** and **Herbalism range icon**. 💙

**A huge thank-you to SimonPdv** for creating Opulent Casting Bars and for the artwork that makes MoonRange's look possible.

*Opulent Casting Bars is a separate addon, not a required dependency. MoonRange is an independent fan project and is not an official extension of, or endorsed by, its creator.*

---

## 🪄 Let's get you set up!

1. Download the MoonRange files from this repository.
2. Put the **`MoonRange`** folder into your WoW Forever **`Interface/AddOns/`** folder.
3. Keep the **`Textures/`** folder and all its included **`.tga`** artwork inside MoonRange.
4. Enable the addon from your in-game AddOns list.
5. Enter the world and open the settings with **`/moonrange`**.

### 🦋 A little tour of the settings

| Page | The fun stuff |
|---|---|
| **🌙 Nameplates** | Pick Moon or Herbalism, customise fonts, preview your range indicator's appearance, and position names, levels, and native cast bars. |
| **✨ Spells** | **The main event:** choose the spell MoonRange uses for its range checks. |
| **💗 Profiles** | See the current character's settings. Each character has their own saved setup. |

**Candy tip:** The spell you select is the entire point! Pick the ability whose range you care about most — different spells can reach different distances.

---

## 🐛 Oh no, a gremlin!

Bugs happen. Even moon magic has its moments. 🫠

<div align="center">

### 🌙 [✧ OPEN THE MOONRANGE BUG REPORT PORTAL ✧](https://candyblk95.github.io/MoonRange/bug-portal/)

**Found a Blizzard Lua error? Please send it my way!**

</div>

Just **copy the full Blizzard Lua error**, paste it into the portal, tell me what you were doing when it happened, and select **Prepare GitHub bug report**.

The portal helps you format a report for [GitHub Issues](https://github.com/Candyblk95/MoonRange/issues), where I can investigate and fix it.

<sub>You'll need a GitHub account to submit the issue. Reports are public, so please remove any private information. The portal doesn't automatically change anyone's Lua files.</sub>

---

## 🔧 A peek behind the moonlight

For the curious little code goblins:

- **Client:** WoW Forever **1.60.1**
- **Range API:** `C_Spell.IsSpellInRange`
- **Bars:** Blizzard's underlying nameplate health and cast bars are preserved.
- **Themes:** Moon and Herbalism.
- **Settings:** Saved separately for each character.
- **Status:** A growing addon — bug reports and testing feedback are always appreciated!

---

<div align="center">

### ✧ Adapted with love by Candy Black ✧

*For the moon children, the forest witches, the Night Elves, and everyone who wants their UI to look a little more magical.*

**Original artwork: SimonPdv (Opulent Casting Bars)** · **MoonRange additions: Candy Black**

**Elune-adore, lovely.** 🌙💙

[**MoonRange Home**](https://candyblk95.github.io/MoonRange/) · [**Bug Portal**](https://candyblk95.github.io/MoonRange/bug-portal/) · [**Opulent Casting Bars**](https://www.curseforge.com/wow/addons/opulent-casting-bars)

</div>

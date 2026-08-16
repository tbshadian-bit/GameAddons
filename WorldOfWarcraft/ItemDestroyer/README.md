# Item Destroyer

A World of Warcraft addon for **Midnight (patch 12.1)** that destroys the item
your mouse is hovering over in your bags, triggered from a macro.

## ⚠️ Warning

Destroying an item is **permanent**. This addon does not ask "are you sure?"
for ordinary items — the whole point is a one-press destroy. Read the safety
section below before using it.

## Installation

1. Copy the `ItemDestroyer` folder into your WoW AddOns directory, e.g.:
   `World of Warcraft/_retail_/Interface/AddOns/ItemDestroyer`
2. Restart WoW (or reload UI with `/reload`) and make sure the addon is
   enabled on the character select / addon list screen.

## Creating the macro

1. Open the macro UI (`/macro` or `/m`) and create a new macro.
2. Set the macro body to:
   ```
   #showtooltip
   /destroyitem
   ```
3. Drag the macro onto an action bar.
4. **Bind a keyboard shortcut to that action bar slot** (Key Bindings menu,
   or SHIFT+drag isn't needed — just set a hotkey on the button). You must
   trigger the macro with a **keypress**, not a mouse click on the button —
   clicking the macro with your mouse moves your cursor onto the button
   itself, so there's no longer an item under it.

## Usage

1. Hover your mouse over the item you want to destroy in your bags.
2. Hold **Shift** and press the macro's keybind.
3. The item is destroyed and a confirmation is printed to your chat window.

By default a modifier key (Shift) must be held when you trigger the macro,
as a safety net against destroying something by accident. You can turn this
off or back on:

```
/destroyitem safety off   -- destroy immediately, no modifier required
/destroyitem safety on    -- require Shift again (default)
```

## Notes / limitations

- Only works on items sitting in your bags (not equipped gear, bank, etc.).
- If Blizzard's own client considers the item irreplaceable (e.g. certain
  quest items, BoE epics, unique items), the game will still show its normal
  "Are you sure?" confirmation popup — this addon does not and cannot bypass
  that built-in protection.
- Tested against the default Blizzard bag UI. Some replacement bag addons
  (ElvUI, Bagnon, etc.) are supported on a best-effort basis; if destroying
  doesn't work with your bag addon, hover the item in the default Blizzard
  bag window instead.
- The `## Interface:` version in `ItemDestroyer.toc` targets patch 12.1
  (`120100`). If the game reports the addon as out of date after a patch,
  update that number to match your client's build (Options > AddOns, or
  `/run print(select(4, GetBuildInfo()))`).

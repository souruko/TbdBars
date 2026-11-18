**TbdBars** — LOTRO Quickslot Bar Plugin
Author: Souru | Version: 0.0.5

Displays configurable quickslot bars that automatically swap when you switch your active class specialization (trait line: Red / Yellow / Blue).

---

**Features**
- Multiple independent bar windows per trait line
- Bars swap automatically on specialization change — no manual action needed
- Each bar is independently resizable (in quickslot-unit increments) and freely repositionable
- Ctrl+click to select several bars and drag them as one block, keeping their relative spacing
- Bars snap to the screen centre lines and to each other while dragging, with centre guide lines
- A configurable gap, so bars settle a set number of pixels clear of each other instead of touching
- Named layout snapshots: save and restore window geometry across sessions
- Character-scoped bar data (quickslot assignments stay per character)
- Account-scoped layout data (named layouts shared across all characters on the account)
- German and French client support

---

**Supported Classes**

All twelve playable classes are supported, with all three trait lines each:

> Burglar — The Quiet Knife / The Mischief-maker / The Gambler
> Captain — Lead the Charge / Leader of Men / Hands of Healing
> Beorning — The Claw / The Roar / The Hide
> Mariner — The Duellist / The Rover / The Shanty-caller
> Brawler — The Fulcrum / The Maelstrom / The Fundament
> Champion — The Berserker / The Deadly Storm / The Martial Champion
> Guardian — The Keen Blade / The Fighter of Shadow / The Defender of the Free
> Hunter — Bowmaster / The Trapper / Huntsman
> Rune-keeper — Cleansing Flame / Solitary Thunder / Benedictions of Peace
> Minstrel — The Warrior-skald / The Protector of Song / The Watcher of Resolve
> Lore-master — Master of Nature's Fury / The Ancient Master / Keeper of Animals
> Warden — Recklessness / Assailment / Determination

---

**Installation**

1. Copy the `TbdBars` folder into your LOTRO plugins directory:
   `Documents\The Lord of the Rings Online\plugins\TbdBars`
2. Launch LOTRO and load the plugin:
```
/plugins load TbdBars
```

---

**Commands**

All commands use `/tbd` or `/tbdbars` as the prefix.

`/tbd help` — Print the full command reference (also shown when no argument is given)
`/tbd add <width> <height>` — Add a new quickslot bar (size in quickslot units)
`/tbd remove <index>` — Remove a bar by its index
`/tbd resize <index> <width> <height>` — Resize an existing bar
`/tbd color <index> <r> <g> <b>` — Set a bar's background colour (0–255 per channel)
`/tbd opacity <index> <0-100>` — Set a bar's opacity as a percentage
`/tbd move` — Toggle move mode (drag handles appear on all bars)
`/tbd select all` / `/tbd select none` — Select or deselect every bar
`/tbd select <index> ...` — Add or remove bars from the selection by number
`/tbd gap <pixels>` — Spacing bars keep when they snap beside each other
`/tbd lock` — Toggle quickslot lock; locked bars ignore shortcut changes
`/tbd list` — List all bars with index, size, position, and selection state
`/tbd layout save <name>` — Save current bar geometry as a named layout
`/tbd layout load <name>` — Load a named layout (clears quickslot assignments)
`/tbd layout delete <name>` — Delete a saved layout
`/tbd layout overview` — List all saved layouts

**Examples:**
```
/tbd add 5 1           -- adds a 5-wide, 1-tall bar
/tbd add 3 2           -- adds a 3×2 bar
/tbd remove 2          -- removes bar #2 from the active trait line
/tbd select 1 3        -- selects bars #1 and #3
/tbd gap 5             -- bars now snap 5px clear of each other
/tbd layout save main  -- saves current geometry as "main"
/tbd layout load main  -- restores "main" layout
```

---

**Moving several bars at once**

Turn on move mode with `/tbd move`, then hold **Ctrl** and left-click a bar's yellow handle to add
it to the selection — the handle turns cyan. Ctrl+click it again to drop it back out. Dragging any
selected handle moves every selected bar together and keeps their spacing unchanged.

Dragging a handle that is *not* selected clears the selection and moves just that bar, so plain
dragging works exactly as it always did. `/tbd select all` grabs every bar at once, and
`/tbd select <index>` reaches a bar whose handle is hidden under another one.

The selection covers only the trait line you are currently on, and is cleared when you leave move
mode or remove a bar.

---

**Lining bars up**

Two guide lines mark the centre of the screen while move mode is on. As you drag, a bar snaps onto
either centre line — by its own centre or by one of its edges — and onto other bars, once it comes
within a few pixels. The guide line brightens while a bar is sitting on it. Hold **Alt** while
dragging to ignore snapping entirely and place a bar freely.

Snapping to another bar comes in two flavours:

- **Beside it** — the bar comes to rest `/tbd gap` pixels clear of its neighbour's edge.
- **In line with it** — edges and centre axes line up exactly, with no gap. This is never affected
  by the gap setting; lining up is lining up.

So set the spacing once and then just drag:

```
/tbd gap 5             -- bars settle 5px clear of each other
/tbd gap 0             -- back to flush
/tbd gap               -- report the current value
```

The gap is saved per character, and it does not affect the screen centre lines — centred is centred.

Bars can no longer be dragged off the screen; they stop with the move handle still reachable. The
handle occupies the 20 pixels above the bar, so a bar's own top edge cannot go higher than `y = 20`.

---

**Reloading after an update** (no restart needed):
```
/plugins unload TbdBars
/plugins load TbdBars
```

---

**Notes**
- Specialization detection works by listening for the in-game advancement chat message that fires when you commit a trait line. Bars swap automatically at that point.
- Loading a layout replaces window geometry for the active trait line only and clears all quickslot assignments — you'll need to re-slot your abilities.
- Bar data is saved per character; layout data is saved per account.

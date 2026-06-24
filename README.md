# TbdBars

A Lord of the Rings Online (LOTRO) plugin that displays configurable quickslot bars which automatically swap when the player switches their active class specialization (trait line).

**Author:** Souru  
**Version:** 0.0.2

## Features

- Multiple independent quickslot bar windows per trait line (Red / Yellow / Blue)
- Bars swap automatically when you change your active specialization — no manual action required
- Each bar is independently resizable (in quickslot-unit increments) and freely repositionable
- Named layout snapshots: save and restore window geometry across sessions
- Character-scoped bar data (quickslot assignments stay per character)
- Account-scoped layout data (named layouts are shared across characters on the same account)
- German and French client support

## Supported Classes

All twelve playable classes are supported:

| Class | Red | Yellow | Blue |
|---|---|---|---|
| Burglar | The Quiet Knife | The Mischief-maker | The Gambler |
| Captain | Lead the Charge | Leader of Men | Hands of Healing |
| Beorning | The Claw | The Roar | The Hide |
| Mariner | The Duellist | The Rover | The Shanty-caller |
| Brawler | The Fulcrum | The Maelstrom | The Fundament |
| Champion | The Berserker | The Deadly Storm | The Martial Champion |
| Guardian | The Keen Blade | The Fighter of Shadow | The Defender of the Free |
| Hunter | Bowmaster | The Trapper | Huntsman |
| Rune-keeper | Cleansing Flame | Solitary Thunder | Benedictions of Peace |
| Minstrel | The Warrior-skald | The Protector of Song | The Watcher of Resolve |
| Lore-master | Master of Nature's Fury | The Ancient Master | Keeper of Animals |
| Warden | Recklessness | Assailment | Determination |

## Installation

1. Copy the `TbdBars` folder into your LOTRO plugins directory:
   - Default: `Documents\The Lord of the Rings Online\plugins\TbdBars`
2. Launch LOTRO and load the plugin:
   ```
   /plugins load TbdBars
   ```

## Commands

All commands use `/tbd` or `/tbdbars` as the prefix.

| Command | Description |
|---|---|
| `/tbd add <width> <height>` | Add a new quickslot bar (`width` and `height` in quickslot units) |
| `/tbd remove <index>` | Remove a bar by its index |
| `/tbd move` | Toggle move mode — drag handles appear on all bars |
| `/tbd layout save <name>` | Save the current bar geometry as a named layout |
| `/tbd layout load <name>` | Load a named layout (window geometry only; quickslot assignments are cleared) |
| `/tbd layout overview` | List all saved layouts |

### Examples

```
/tbd add 5 1          -- adds a 5-wide, 1-tall bar
/tbd add 3 2          -- adds a 3×2 bar
/tbd remove 2         -- removes bar #2 from the active trait line
/tbd layout save main -- saves current geometry as "main"
/tbd layout load main -- restores "main" layout
```

## Reloading

After installing an update, reload without restarting the client:

```
/plugins unload TbdBars
```

## Notes

- Specialization detection works by listening for the in-game advancement chat message that appears when you commit a trait line. Bars swap automatically at that point.
- Loading a layout replaces window geometry for the active trait line only and clears all quickslot assignments for those windows — you will need to re-slot your abilities.
- The plugin saves bar data per character and layout data per account.

# Changelog

## [0.0.6] - 2026-11-19

### Added
- `/tbd clear` — empties quickslots, which until now there was no way to do at all. `/tbd clear 2` empties bar #2, `/tbd clear 2 5` empties just slot 5 of it, and `/tbd clear all` empties every bar on the trait line you are on. Slots are counted left to right and then top to bottom. This exists because dragging a shortcut off a bar does *not* empty the slot: the game hands out a copy and keeps the original where it is, so there is no drag gesture a plugin can hook for this.
- `/tbd list` now shows how many of each bar's slots are filled, so the slot numbers `/tbd clear` wants are easy to work out.

### Changed
- `/tbd lock` now actually locks. While it is on, nothing can be dropped onto a bar — it used to let the change through on screen and simply not write it down, so the bar you were looking at and the bar you got back after a reload were different bars. Clicking a slot to use the skill still works exactly as normal, so a locked bar is a working bar, just a fixed one. Be aware of what the game lets a plugin do here: a locked bar cannot turn a drop away at the door, it has to put the old skill back immediately afterwards, so you may catch a flicker of the dropped icon before your own skill reappears. `/tbd clear` is refused while the lock is on, and says so.
- The lock is remembered. It stays on across a specialization change and across a relog, where before it quietly switched itself off every time your bars swapped.
- `/tbd list` marks the trait line as `[locked]` while the lock is on, since it now persists and is easy to leave on by accident.
- `/tbd help` describes what the lock does, points at `/tbd clear`, and explains why dragging a shortcut off a bar does not empty it

### Fixed
- An emptied slot no longer comes back. A slot with nothing in it was being written to the save file as a broken entry and handed back to the game on every rebuild, so even once there was a way to clear a slot it would not have stuck.

## [0.0.5] - 2026-11-19

### Added
- Bars now snap into place while you drag them. A bar jumps onto the screen's centre line, or beside another bar, or into line with another bar's edge or centre, once it comes within a few pixels — so lining bars up no longer means reading coordinates off the move handle. Hold Alt while dragging to ignore snapping and place a bar exactly where you want it.
- Two guide lines mark the centre of the screen for as long as move mode is on, and brighten while a bar is sitting on one.
- `/tbd gap <pixels>` — sets the spacing a bar keeps when it snaps beside another one. Set it to 5 and bars come to rest 5px clear of each other instead of touching; set it back to 0 for flush. Lining up edges and centres is unaffected — only sitting *next to* a bar uses the gap. `/tbd gap` on its own reports the current value.

### Changed
- Bars can no longer be dragged off the edge of the screen. They stop with the move handle still reachable, and a bar that had already been lost off the edge is brought back the first time you drag it.
- When several bars are selected, the group now stops at a screen edge as a block, so the spacing you set up between them is never squashed.
- `/tbd help` now mentions snapping, the snap gap and the Alt override

## [0.0.4] - 2026-11-18

### Added
- Several bars can now be moved at once. In move mode, hold Ctrl and left-click a bar's handle to add it to the selection — the handle turns cyan. Dragging any selected handle then moves every selected bar together, keeping their spacing exactly as it was.
- `/tbd select all` and `/tbd select none` — select or deselect every bar on the active trait line
- `/tbd select <index> ...` — add or remove bars from the selection by number, useful when two handles overlap and are awkward to click
- `/tbd list` now marks the bars that are currently selected

### Changed
- `/tbd help` now explains the multi-select gesture
- The selection only ever covers the trait line you are currently on, and is cleared when you leave move mode or remove a bar
- Dragging a bar that is not part of the selection clears the selection first, so a plain drag always moves just that one bar

## [0.0.3] - 2026-06-24

### Added
- `/tbd help` — prints full command reference (also shown when no argument is given)
- `/tbd list` — lists all bars on the active trait line with index, size, and position
- `/tbd resize <index> <w> <h>` — resizes an existing bar without removing and re-adding it
- `/tbd color <index> <r> <g> <b>` — sets bar background color (0–255 per channel)
- `/tbd opacity <index> <0-100>` — sets bar opacity as a percentage
- `/tbd lock` — toggles quickslot lock; locked bars ignore shortcut changes
- `/tbd layout delete <name>` — deletes a saved layout
- `Data.version` field written on fresh install for future save-schema migrations

### Changed
- New windows now cascade their spawn position (each offset by 50px) instead of all appearing at (200, 200)
- `add` and `remove` commands now print a confirmation message on success
- Unknown commands now print a helpful error message instead of silently doing nothing
- `/tbd layout` with no subcommand now prints usage instead of a generic error

### Fixed
- Opacity field was stored but never applied; `SetOpacity` is now called on the background panel when a window is created
- "Acitv." typo in the layout-load confirmation message corrected to "Active"
- Move handles no longer disappear after removing a bar while in move mode

## [0.0.2] - 2026-06-24

### Changed
- Refactored layout management: `SaveLayout`, `LoadLayout`, and `PrintLayout` moved to `LayoutChanges.lua`
- Refactored save/load into dedicated `Load_Save.lua`; data initialisation and `ConvertToEuro`/`ConvertFromEuro` helpers consolidated there
- `DataFunctions.lua` introduced for `AddNewWindow` and `RemoveWindow` helpers

## [0.0.1] - 2022-05-24

### Added
- Named layout save/load/overview (`/tbd layout save|load|overview`)
- Account-scoped layout persistence via `Turbine.DataScope.Account`

## [0.0.0] - 2022-04-24

### Added
- Initial plugin skeleton with `TbdBars.plugin` manifest
- Global state: `Data`, `Layout`, `Activ_Cluster`, locale detection, trait line constants, `ClassStrings` map for all twelve classes
- `QuickslotWindow` UI element — draggable, resizable quickslot bar
- `Cluster` — manages a set of `QuickslotWindow` instances for one trait line
- Add and remove windows via `/tbd add <w> <h>` and `/tbd remove <index>`
- Move mode toggle via `/tbd move`
- Automatic bar swap on specialization change (listens for advancement chat messages)
- Character-scoped save via `Turbine.DataScope.Character`
- DE/FR client workaround: `ConvertToEuro`/`ConvertFromEuro` for numeric table keys

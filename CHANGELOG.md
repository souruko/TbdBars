# Changelog

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

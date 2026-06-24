# Changelog

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

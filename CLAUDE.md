# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

TbdBars is a Lord of the Rings Online (LOTRO) game plugin written in Lua. It displays configurable quickslot bars that automatically swap when the player changes their active class specialization (trait line: Red/Yellow/Blue).

There is no build step and no test runner. The plugin runs inside the game client via the Turbine API. To test changes, reload the plugin in-game with `/plugins reload TbdBars` or restart the client.

## Deployment

The primary working directory **is** the live game plugin directory (via Steam Proton at `steamapps/compatdata/212500/pfx/...`). There is a second working directory at `/home/souru/lotro/documents_live/plugins/TbdBars` that mirrors this location. Both paths point to the same plugin for LOTRO.

## Architecture

**Load order** (defined by `Main.lua`):
1. `Globals.lua` — sets up global state: `Data`, `Layout`, `Activ_Cluster`, locale detection, `LOCALPLAYER`, `LP_CLASS`, trait line constants, and the `ClassStrings` map (used to detect specialization changes from chat messages)
2. `Utils/` — OOP helpers (`class()`, `static_class()`, `abstract_class()`, `final_class()`) and `Utils.ColorFix()`
3. `Elements/` — UI classes: `QuickslotWindow` (a single draggable bar) and `Cluster` (manages a set of windows for one trait line)
4. `Load_Save.lua` — populates `Data` (character-scoped) and `Layout` (account-scoped) from `Turbine.PluginData`, defines `Save()` and `SaveLayoutData()`; includes `ConvertToEuro`/`ConvertFromEuro` for DE/FR client workaround
5. `Main.lua` — instantiates `Activ_Cluster` from `Data[Data.activ]`
6. `LayoutChanges.lua` — hooks `Turbine.Chat.Received` to detect specialization changes via advancement chat messages and calls `LayoutChanged()`; also defines `LoadLayout()`, `SaveLayout()`, `PrintLayout()`
7. `ChatCommands.lua` — registers `/tbd` and `/tbdbars` shell commands

**Data model:**
- `Data` (character save): a table keyed by trait line number (1=Red, 2=Yellow, 3=Blue). Each entry is a list of window data tables with fields `left`, `top`, `width` (in quickslot units), `height`, `color`, `opacity`, `quickslots`.
- `Layout` (account save): named layout snapshots (window geometry only, no quickslot assignments).
- `Data.activ`: the currently active trait line index.

**Key globals:** `Activ_Cluster`, `Data`, `Layout`, `Locale`, `LOCALPLAYER`, `LP_CLASS`, `QS_SIZE` (36px), `FRAME` (1px)

## In-game commands

```
/tbd add <width> <height>       -- add a new quickslot window
/tbd remove <index>             -- remove a window by index
/tbd move                       -- toggle move mode (shows drag handles)
/tbd layout save <name>         -- save current window geometry as a named layout
/tbd layout load <name>         -- load a named layout (clears quickslot assignments)
/tbd layout overview            -- list saved layouts
```

## Turbine API conventions

- `import "Package.Name"` loads a module (maps to `require` in the Lua language server)
- `__init__.lua` is the package entry point for each directory
- UI classes inherit from `Turbine.UI.Window`, `Turbine.UI.Label`, etc.
- `Turbine.PluginData.Save/Load` persists data; `DataScope.Character` is per-character, `DataScope.Account` is account-wide
- Event handlers are assigned by overwriting methods: `window.MouseDown = function(sender, args) ... end`

## DE/FR client workaround

The German and French LOTRO clients cannot store numeric table keys in `PluginData`. `ConvertToEuro` converts all numbers to strings before saving; `ConvertFromEuro` converts them back after loading. This conversion is applied in `Save()` and `SaveLayoutData()` when `Locale ~= LANGUAGE.English`.

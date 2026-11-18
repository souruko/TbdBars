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
3. `Elements/` — UI classes: `QuickslotWindow` (a single draggable bar), `Guides` (the two screen-centre guide lines) and `Cluster` (manages a set of windows for one trait line). `Guides` must be imported before `Cluster`, which constructs one
4. `Load_Save.lua` — populates `Data` (character-scoped) and `Layout` (account-scoped) from `Turbine.PluginData`, defines `Save()` and `SaveLayoutData()`; includes `ConvertToEuro`/`ConvertFromEuro` for DE/FR client workaround
5. `Main.lua` — instantiates `Activ_Cluster` from `Data[Data.activ]`
6. `LayoutChanges.lua` — hooks `Turbine.Chat.Received` to detect specialization changes via advancement chat messages and calls `LayoutChanged()`; also defines `LoadLayout()`, `SaveLayout()`, `PrintLayout()`
7. `ChatCommands.lua` — registers `/tbd` and `/tbdbars` shell commands

**Data model:**
- `Data` (character save): a table keyed by trait line number (`TRAIT_LINE` in `Globals.lua` — 1=Blue, 2=Red, 3=Yellow). Each entry is a list of window data tables with fields `left`, `top`, `width` (in quickslot units), `height`, `color`, `opacity`, `quickslots`.
- `Layout` (account save): named layout snapshots (window geometry only, no quickslot assignments).
- `Data.activ`: the currently active trait line index.
- `Data.gap`: pixels a bar keeps when it snaps beside another. Seeded to 0 in `Load_Save.lua` **outside** the fresh-install branch, so savefiles written before the setting existed get a value.
- `Data.locked`: boolean, the quickslot lock. Seeded in `Load_Save.lua` alongside `Data.gap` and read by `Cluster:Constructor` — **not** defaulted to `false` there, because a trait-line swap throws the cluster away and builds a new one, so the only place the lock can survive one is `Data`. Booleans round-trip the euro conversion safely (`tonumber(true)` is `nil` in Lua 5.1, so `ConvertFromEuro`'s fallback keeps them).
- `Cluster.selection`: set of selected window indices. **Runtime only, never saved** — adding it to a window's data table would push it through `ConvertToEuro` and the `Layout` copies.
- A cleared slot is **absent** from `data.quickslots`, not stored as an Undefined entry. The hole is safe: every reader indexes explicitly and the euro converters walk with `pairs`.

**Key globals:** `Activ_Cluster`, `Data`, `Layout`, `Locale`, `LOCALPLAYER`, `LP_CLASS`, `QS_SIZE` (36px), `FRAME` (1px), `MOVE_HEADER_WIDTH` (200) / `MOVE_HEADER_HEIGHT` (20), `SNAP_DISTANCE` (8px), `MOVE_HEADER_COLOR` / `MOVE_HEADER_COLOR_SELECTED`, `GUIDE_*`

## In-game commands

```
/tbd add <width> <height>       -- add a new quickslot window
/tbd remove <index>             -- remove a window by index
/tbd resize <index> <w> <h>     -- resize a window
/tbd color <index> <r> <g> <b>  -- set background colour (0-255 per channel)
/tbd opacity <index> <0-100>    -- set opacity
/tbd move                       -- toggle move mode (shows drag handles)
/tbd select all|none            -- select or deselect every window
/tbd select <index> ...         -- toggle selection of windows by index
/tbd gap <pixels>               -- spacing kept when a bar snaps beside another
/tbd clear all|<bar>|<bar> <slot>  -- empty every slot, a bar, or one slot
/tbd lock                       -- toggle the quickslot lock (persisted; refuses /tbd clear)
/tbd list                       -- list windows with index, size, position, selection
/tbd layout save <name>         -- save current window geometry as a named layout
/tbd layout load <name>         -- load a named layout (clears quickslot assignments)
/tbd layout delete <name>       -- delete a saved layout
/tbd layout overview            -- list saved layouts
```

## Multi-bar selection and group drag

In move mode, ctrl+left-click a bar's handle to toggle it in `Cluster.selection`; dragging a
selected handle moves every selected bar by the same delta. Three things to know before touching it:

- **Mouse event args carry only `Button`, `X`, `Y`.** `Control`/`Shift`/`Alt` exist only on *key*
  event args. Modifier state at click time comes from the static `Turbine.UI.Control.IsControlKeyDown()`,
  wrapped as `Utils.IsAddToSelectionDown(args)` in `Utils/Misc.lua` — that is the one place to
  change if the client ever swallows ctrl+left-click.
- **The drag delta is per-event, not cumulative.** `args.X` is header-local and the header moves
  with its window, so `args.X - dragStartX` is the increment for that event. `Cluster:DragBy` fans
  that increment out to every selected window and moves the grabbed one exactly once.
- **Window indices are not stable identities.** `RemoveWindow` swaps the last entry into the freed
  slot, so `/tbd remove` clears the selection first. `/tbd add` appends and leaves indices intact,
  so it must *not* clear. `Cluster:Reload()` prunes vanished indices and re-applies the highlight,
  the same way it already re-applies `moving` and `locked`.

## Quickslot contents: clearing and locking

`QuickslotWindow:OnShortcutChanged` is the single handler for every way a slot's contents change,
and `QuickslotWindow:ApplyShortcut` is the single caller of `SetShortcut`. Four facts cost real
effort to establish and are not discoverable from the API stubs:

- **A plugin quickslot is a copy source. Dragging a shortcut off one does not empty it, and fires
  nothing.** Measured in-game 2026-11-19 on U50: dragging a shortcut away, and dragging it onto
  another quickslot, both leave the original slot exactly as it was. So there is **no drag-off
  gesture to hook** and clearing has to be plugin-driven — hence `QuickslotWindow:ClearSlots`,
  `Cluster:ClearSlots` and `/tbd clear`. This cost a wrong turn: `Basil/UI/PostButton.lua:224-228`
  carries a comment reading "a user who drags the alias off the slot is left with a dead button",
  which *looks* like evidence that drag-off empties a slot. It is not — do not infer behaviour from
  that comment. The savefiles were the tell all along: across five characters there has never been a
  single `Type = 0` entry.
- **`ShortcutChanged` fires on a drop *in* and on your own `SetShortcut`**, and its args table is
  **empty** — the new state has to be read back with `sender:GetShortcut()`. Because our own
  `SetShortcut` re-enters, the `restoring` guard flag is mandatory, not defensive. The "slot is now
  empty" branch in `OnShortcutChanged` is therefore defensive only; `/tbd clear` updates
  `data.quickslots` itself precisely because `ApplyShortcut` raises the guard and the handler never
  sees our own write.
- **Never `SetShortcut(nil)`.** The shared Turbine library in `../Turbine/UI/Lotro/Quickslot.lua`
  monkey-patches `Quickslot:SetShortcut` to call `self:SetVisible( value )` afterwards — passing the
  Shortcut *object* to a boolean setter. It is live here (`Main.lua`'s `import "Turbine.UI.Lotro"`
  pulls in `Turbine/UI/Lotro/__init__.lua`, which imports it). A real Shortcut table is truthy so the
  slot stays visible; `nil` hides it for good. A blank slot is therefore
  `Shortcut( ShortcutType.Undefined, "" )`. Every `SetShortcut(nil)` in the sibling plugins is
  `pcall`'d or commented out for this reason.
- **An emptied slot reports `ShortcutType.Undefined` (0).** Storing that is the old clearing bug:
  `CreateQuickslots` would then try to restore it. Delete the entry instead.
- **`SetAllowDrop(false)` does not block a drop onto a Quickslot** — "the game puts it into the slot
  anyway" (`../Bovven/StatsToolbox/WindowGear.lua:456`), and PrimePlugins tried it and commented it
  out in three separate files. There is no veto flag on `DragEnter`/`DragStart`, and `DragDropInfo`
  offers only `IsSuccessful`/`SetSuccessful`. **So the lock is a revert, not a refusal**: the drop
  lands and the old shortcut goes straight back, which is what PrimePlugins' own locked skill bars
  do. The only true block is `SetMouseVisible(false)` or a mouse-eating overlay, and both kill the
  click that uses the skill. Do not reintroduce `SetAllowDrop` here.

`SetLocked` is now just a flag write — the handler consults `self.locked` at call time. Swapping the
handler in and out was what made the old lock a save suppressor rather than a lock. `CreateQuickslots`
seeds `self.locked` from the cluster it is handed, so a bare `ResetQuickslots` cannot silently unlock
a bar; `Cluster:Reload`'s locked pass is belt-and-braces.

## Positioning: snapping, guides, clamping

`Cluster:SnapDelta` adjusts every drag delta before it is applied, and `QuickslotWindow:MoveTo` is
the single writer of position and therefore the single clamp site. Things that cost real effort to
work out:

- **`data.top` is 20px above the visible bar.** The move header occupies the top of the window
  whether or not it is visible, so the visible rect is `(data.left, data.top + MOVE_HEADER_HEIGHT,
  …)`. Use `Utils.BarRect(data)` — never recompute it inline. The offset is the same for every bar,
  so it cancels out of bar-to-bar maths (shared edges, gaps) and only bites when comparing against
  the screen; getting it wrong puts a "centred" bar 10px high.
- **The clamp uses `Utils.WindowSize` (bar + header), not the bar rect.** A bar whose visible top
  reached `y = 0` would have its handle at `-20..0` and could never be grabbed again — which is the
  problem the clamp exists to solve. The cost is that a bar's visible top cannot go above `y = 20`.
  Far edge is clamped before the near edge, so an oversized rect keeps its top-left on screen.
- **Group drags clamp the group's bounding box, not each bar.** Per-bar clamping squashes the
  group's relative offsets the moment one member reaches an edge, so `SnapDelta` folds the group
  clamp into the returned delta and the per-bar clamp in `MoveTo` becomes a no-op.
- **A snap candidate is an explicit `{ moving edge, target, is_screen_centre }` triple**, not an
  edge list crossed with a target list. That restructure exists because `Data.gap` applies only to
  *adjacency* (my left edge against your right edge, gap pixels clear) and never to *alignment* (my
  left edge against your left edge). A loose cross product cannot express the difference.
- **Snap targets exclude the moving group by membership, not by selection** — dragging an unselected
  bar while a selection exists must still be able to snap to the selected bars. The screen centre is
  listed first and ties are broken with a strict `<`, so it wins against a bar edge. The gap never
  touches the screen centre candidates.
- **`Turbine.UI.Display` has no resolution-change event and no UI-scale getter** — only six static
  getters. `Guides:Refresh()` is therefore called on the move-mode toggle and on `Reload()` rather
  than in response to a resize.
- **A guide line must be a top-level `Turbine.UI.Window`**, not a `Control` (a Control is clipped to
  its parent and cannot draw over the game world), every piece `SetMouseVisible(false)` or it eats
  the drag, and both windows must be closed in `Guides:Close()` or they survive a `/plugins refresh`
  as orphans. A 1px line is hard to see against terrain, hence the bright edge over a dark core —
  the same conclusion `Gibberish3/OPTIONS2/MOVE/Window.lua:184-211` reached.
- `Guides:SetActive` only calls `SetBackColor` on an actual state change, because it runs on every
  mouse-move event.

## Turbine API conventions

- `import "Package.Name"` loads a module (maps to `require` in the Lua language server)
- `__init__.lua` is the package entry point for each directory
- UI classes inherit from `Turbine.UI.Window`, `Turbine.UI.Label`, etc.
- `Turbine.PluginData.Save/Load` persists data; `DataScope.Character` is per-character, `DataScope.Account` is account-wide
- Event handlers are assigned by overwriting methods: `window.MouseDown = function(sender, args) ... end`

## DE/FR client workaround

The German and French LOTRO clients cannot store numeric table keys in `PluginData`. `ConvertToEuro` converts all numbers to strings before saving; `ConvertFromEuro` converts them back after loading. This conversion is applied in `Save()` and `SaveLayoutData()` when `Locale ~= LANGUAGE.English`.

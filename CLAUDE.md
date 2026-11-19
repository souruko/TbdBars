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
3. `Elements/` — UI classes: `GapFrame` (the snap-gap band drawn around one bar), `QuickslotWindow` (a single draggable bar), `Guides` (the two screen-centre guide lines) and `Cluster` (manages a set of windows for one trait line). Each is imported before whatever constructs it: `GapFrame` before `QuickslotWindow`, `Guides` before `Cluster`
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
- `data.scale`: per-bar scale factor, 0.5–5. **Never defaulted on load** — `Utils.ScaleOf` reads it lazily (`tonumber`, nil → 1, clamped), which is what makes old savefiles, old `Layout` snapshots and `LoadLayout`'s hand-copied tables all correct without a migration pass. `AddNewWindow` seeds `1` only so it is visible in the savefile. Contrast `Data.gap`/`Data.locked`, which *are* seeded in `Load_Save.lua` because they are cluster-wide and have no per-read accessor.

**Key globals:** `Activ_Cluster`, `Data`, `Layout`, `Locale`, `LOCALPLAYER`, `LP_CLASS`, `QS_SIZE` (36px), `FRAME` (1px), `MOVE_HEADER_WIDTH` (200) / `MOVE_HEADER_HEIGHT` (20), `SNAP_DISTANCE` (8px), `SCALE_MIN` (0.5) / `SCALE_MAX` (5), `MOVE_HEADER_COLOR` / `MOVE_HEADER_COLOR_SELECTED`, `GUIDE_*`, `GAP_FRAME_COLOR` / `GAP_FRAME_OPACITY`

## In-game commands

```
/tbd add <width> <height>       -- add a new quickslot window
/tbd remove <index>             -- remove a window by index
/tbd resize <index> <w> <h>     -- resize a window
/tbd scale <factor>             -- scale the selected bars, 0.5-5, two decimals
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

In move mode, a plain left-click on a bar's handle makes it the whole selection
(`Cluster:SelectOnly`) and ctrl+left-click toggles it in `Cluster.selection`; dragging a selected
handle moves every selected bar by the same delta. Four things to know before touching it:

- **A plain click on an already-selected bar must leave the selection alone**, otherwise a group
  drag could only ever be started from a bar that is not in the group — i.e. never. So
  `QuickslotWindow`'s `MouseDown` calls `SelectOnly` only when the clicked bar is unselected, and
  the drag starts either way.

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
  …)`. Use `Utils.BarRect(data)` — never recompute it inline; it and `Utils.WindowSize` are the only
  two places that know a bar's pixel size, and since `/tbd scale` that size is per bar. The offset is the same for every bar,
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
- **Snap targets exclude the moving group by membership, not by selection** — `DragBy` decides the
  moving group, and only that group may be excluded; a bar that is merely selected but not dragged
  is still a valid snap target. (Since a plain click selects the bar it grabs, the two now coincide
  in practice — keep the membership test anyway, it is the one that is true by construction.)
  The screen centre is
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
- **The gap is drawn per bar, by `Elements/GapFrame.lua`, not by `Guides`.** One `GapFrame` per
  `QuickslotWindow`, four bands of `Utils.GapSize()` pixels hugging `Utils.BarRect`. Four points:
  - **Four bands, not one box behind the bar.** A box would have to draw *under* the bar, and the
    API has no way to state the z-order of two top-level windows against each other. Bands leave the
    bar's own pixels alone, so there is nothing to lose that fight over. Top and bottom run the full
    outer width and so carry the corners; the sides stay the bar's own height.
  - **They must be top-level windows and they must be `SetMouseVisible(false)`.** The frame reaches
    outside its bar's window and a `Window` clips its children, so a child control cannot draw
    there — and the top band lands in the same 20px strip as the move handle, where a mouse-visible
    band would eat the very drag it illustrates. Being top-level, they are orphaned by a
    `/plugins refresh` unless `QuickslotWindow:Closing` closes them.
  - **The bands are translucent on purpose**, both because the top one overlaps the move handle and
    because a solid band reads as another bar rather than as empty ground. `GapFrame:Constructor`
    bounces `SetOpacity` through 0 first — a window starts fully opaque and LOTRO drops a setter
    whose value has not changed (the `ForceOpacity` trap).
  - **`QuickslotWindow:RefreshGapFrame` reads move mode off `self.cluster.moving`** rather than
    mirroring it into a field, since `Cluster:Move` sets that flag before calling round the windows.
    It is called from `MoveTo` — the single writer of position, so a drag updates the frame for
    free — from `Move()`, and from `Cluster:GapChanged`. `GapFrame:Apply` is the one place that
    decides there is a frame to show at all (move mode *and* a non-zero gap), and a gap of 0 returns
    before touching any geometry, which is both honest and the guard that keeps `SetSize(0, …)` off
    a band.
- `Utils.GapSize` is the one reader of `Data.gap`, used by both `SnapDelta` and `GapFrame`. The snap
  maths only ever added the gap to something and so survived a euro-client string; `SetSize` is a
  real API call and will not take one.

## Scaling

`/tbd scale` gives each bar its own `data.scale`. Five things cost real effort and are not
discoverable from the API stubs or from reading the code:

- **`SetSize` on a Quickslot does not scale the icon.** It gives you a big hit box around art that
  is still 36px. The art scales only under **stretch mode 1**, and the mode is useless unless the
  control is at the image's original size *before* the mode is assigned — that assignment is what
  latches the reference size everything afterwards is measured against. Every other mode is a dead
  end: **2 and 4 stop the control receiving mouse events at all**, which would kill the click that
  fires the skill, and 0 and 3 crop rather than scale. (Stub:
  `~/.vscode/extensions/lunarwtr.lotro-api-*/resources/Lua/EmmyLua/Turbine/Turbine.lua:3831-3846`.)
  Prior art is `PrimePlugins/RaidTools/PrimeUITools/SkillBarQuickslots.lua:170-182`, and
  PrimePlugins ships a player-facing 0.5×–3× quickslot scale slider built on it.
- **The bounce through native size in `ApplySlotSize` is mandatory, not defensive.** LOTRO drops a
  setter whose value has not changed — the `ForceZOrder`/`ForceOpacity` trap from the parent
  `CLAUDE.md`. On a re-apply, `SetStretchMode(1)` and `SetSize(target)` would both be silent no-ops
  and the art would never come back. Moving the size to native first makes both writes real.
- **Assigning a shortcut resets the art to native**, so the stretch has to be re-applied after every
  `SetShortcut` and after every drop. `ApplyShortcut` covers our own writes; `OnShortcutChanged`
  covers real drops and calls `ApplySlotSize` **before** its `SameShortcut` early return, because
  dropping the skill a slot already holds changes nothing we save but still perturbs the art.
  PrimePlugins re-applies from its own handler for the same reason
  (`PrimeUIQuickSlot.lua:108-113`); `Bovven/StatsToolbox/GearButtons.lua:91-93` independently
  describes the art being latched to the control's geometry at assignment time.
- **A stretched control renders outside its parent but only takes mouse events inside it.** The
  background has to grow with the slots or the outer ring of each slot is painted and dead. It does,
  because `Utils.BarRect` drives it — but any future change that sizes the background separately
  will reintroduce this, and it looks like "scaling works" until someone clicks a corner.
- **`Utils.SlotArt` / `SlotLead` / `SlotEdge` / `SlotPitch` are the pixel-size authority**, and the
  pitch is `art + lead` — never a rounded `QS_SIZE * scale`. Two reasons. The art is scaled off the stock
  **35** (`QS_SIZE - FRAME`), not off the 36 grid step, so it lands on an exact multiple of its own
  native size (70 at 2×, 105 at 3×) rather than 71 or 109. And rounding the pitch directly instead of
  summing two already-rounded parts leaves the last column a pixel out of its background. At scale 1
  the art is 35 and the pitch is 36, so an unscaled bar never enters stretch mode and its slots sit
  exactly where they always did — that equivalence is the regression to protect.
- **The layout maths is deliberately lop-sided and must stay that way.** The grid starts at
  `Utils.SlotLead` (1px at scale 1) but `BarRect` runs to `Utils.SlotEdge` past the last slot (4px at
  scale 1 — the original `FRAME * 4`). That looks like a bug and is not: a quickslot **insets its own
  art from the top left and draws it flush to the bottom right** (`QS_ART_INSET` in `Globals.lua`),
  so the border a player sees is `lead + inset` on one side and `lead` alone on the other. The uneven
  numbers are what render as an even border. `SlotEdge` is that one value — the border, the trailing
  margin and the gap between two neighbouring icons are all the same number at any scale.

  This cost a wrong turn in 0.0.7 worth not repeating. `FRAME * 4` was "tidied" into a symmetric
  gutter, and every bar at every scale gained a fat top-left edge and a thin bottom-right one. The
  measurement that settled it, from a 2× screenshot: backdrop 74×74, art **64×64 at offset 8,8** — a
  70px control drawing 64px of art at inset 6, i.e. `32/35` of the control at `3/35` of it. Stretch
  mode scales the inset along with everything else, so the compensation has to scale too; it cannot
  stay a constant 4. **Reading a screenshot back pixel by pixel is what proved this** — both the
  wrong theory and the right one looked identical in prose.

Two deliberate non-scalings: **`MOVE_HEADER_HEIGHT` stays a literal 20** at every scale, because it
is baked into the meaning of every saved `data.top` (see *Positioning*) and because keeping it
constant is what lets bars of different scales share all the bar-to-bar maths unchanged; and
**`Data.gap`/`SNAP_DISTANCE` stay literal screen pixels**, since `/tbd gap` is documented in pixels.

`/tbd scale` collects **window indices** before calling `Reload()`, never window objects — `Reload`
destroys every window and builds new ones. It then re-clamps each affected bar with `MoveBy(0, 0)`,
because a scale change never goes through `MoveTo`, which is the only clamp site
(`Gibberish3/OPTIONS2/SHORTCUT/Window.lua:219-229` solves the identical problem the same way).

**`ChatCommands.lua`'s tokenizer is `%S+`, and must stay that way.** It was `%w+`, which is
alphanumerics only and split `3.05` into `3` and `05` — `/tbd scale 3.05` would silently have scaled
by 3. Widening it also stopped layout names being truncated at the first hyphen or underscore.

## Turbine API conventions

- `import "Package.Name"` loads a module (maps to `require` in the Lua language server)
- `__init__.lua` is the package entry point for each directory
- UI classes inherit from `Turbine.UI.Window`, `Turbine.UI.Label`, etc.
- `Turbine.PluginData.Save/Load` persists data; `DataScope.Character` is per-character, `DataScope.Account` is account-wide
- Event handlers are assigned by overwriting methods: `window.MouseDown = function(sender, args) ... end`

## DE/FR client workaround

The German and French LOTRO clients cannot store numeric table keys in `PluginData`. `ConvertToEuro` converts all numbers to strings before saving; `ConvertFromEuro` converts them back after loading. This conversion is applied in `Save()` and `SaveLayoutData()` when `Locale ~= LANGUAGE.English`.

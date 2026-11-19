
--[[
    
    data:

    - left
    - top
    - width (in qickslot count)
    - height (in qickslot count)
    - background color

]]

-- an empty slot reads back two different ways depending on how it was emptied:
-- GetShortcut can hand back nil, or a real Shortcut whose type is Undefined.
-- every reader comes through here and gets nil, nil for "empty", so no caller
-- has to know the difference and no caller indexes a nil shortcut.
local function SlotFields( quickslot )

    local shortcut = quickslot:GetShortcut()

    if shortcut == nil then
        return nil, nil
    end

    local shortcut_type = shortcut:GetType()
    local shortcut_data = shortcut:GetData()

    if shortcut_type == nil
        or shortcut_type == Turbine.UI.Lotro.ShortcutType.Undefined
        or shortcut_data == nil
        or shortcut_data == "" then
        return nil, nil
    end

    return shortcut_type, shortcut_data

end


-- is a saved { Type, Data } entry what the slot is holding right now?
-- compared loosely because the two sides are not guaranteed to be the same lua
-- type: ConvertFromEuro reads every saved scalar back through tonumber, and
-- tonumber("0x70003F0E") is 1879064334, so on a german or french client a saved
-- shortcut id returns as a number while GetData returns a string.
local function SameShortcut( entry, shortcut_type, shortcut_data )

    if entry == nil or shortcut_type == nil then
        return entry == nil and shortcut_type == nil
    end

    return tonumber(entry.Type) == tonumber(shortcut_type)
       and tostring(entry.Data) == tostring(shortcut_data)

end


QuickslotWindow = class( Turbine.UI.Window )

function QuickslotWindow:Constructor(data, index, cluster)
    Turbine.UI.Window.Constructor( self )

    self.data = data
    self.index = index
    self.cluster = cluster
    self.selected = false
    self.dragging = false
    self.quickslots = {}

    -- read from the cluster rather than defaulted to false, so a bar built by a
    -- bare ResetQuickslots is born locked instead of waiting for Cluster:Reload
    -- to lock it again afterwards
    self.locked = ( cluster ~= nil and cluster.locked == true )

    -- taken from Utils rather than recomputed here. the two used to be separate
    -- copies of the same formula, which was survivable while every bar was the
    -- same size and is not now that each one carries its own scale.
    local _, _, width, height = Utils.BarRect( self.data )
    local window_width, window_height = Utils.WindowSize( self.data )

    self:SetPosition(self.data.left, self.data.top)
    self:SetSize(window_width, window_height)
    self:SetMouseVisible(false)

    self.move_header = Turbine.UI.Window()
    self.move_header:SetParent(self)
    self.move_header:SetSize(MOVE_HEADER_WIDTH, MOVE_HEADER_HEIGHT)
    self.move_header:SetPosition( 0 , 0)
    self.move_header:SetBackColor(MOVE_HEADER_COLOR)
    self.move_header:SetMouseVisible(true)

    self.move_header.MouseDown = function( sender, args )
        if args.Button ~= Turbine.UI.MouseButton.Left then
            return
        end

        -- modifier held: add this bar to the selection (or drop it back out of
        -- it), do not start a drag
        if Utils.IsAddToSelectionDown( args ) then
            self.cluster:ToggleSelected( self.index )
            return
        end

        -- a plain click selects this bar alone. clicking one that is already
        -- part of a selection keeps the selection, so a group drag can start
        -- from any of its members
        if not self.cluster:IsSelected( self.index ) then
            self.cluster:SelectOnly( self.index )
        end

        self.dragging = true
        self.dragStartX = args.X
        self.dragStartY = args.Y
    end

    self.move_header.MouseMove = function( sender, args )
        if self.dragging then
            -- args.X is header local and the header moves with the window, so
            -- this delta is the increment for this event, not a running total
            self.cluster:DragBy( self, args.X - self.dragStartX, args.Y - self.dragStartY )
        end
    end

    self.move_header.MouseUp = function( sender, args )
        if args.Button == Turbine.UI.MouseButton.Left then
            self.dragging = false
        end
    end

    -- the gap frame reaches outside this window, so it cannot be a child of it:
    -- a Window clips its children. it is its own set of top level windows,
    -- owned here and closed in Closing.
    self.gap_frame = GapFrame()

    self.move_label = Turbine.UI.Label()
    self.move_label:SetParent(self.move_header)
    self.move_label:SetSize(MOVE_HEADER_WIDTH, MOVE_HEADER_HEIGHT)
    self.move_label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.move_label:SetForeColor(Turbine.UI.Color.Black)
    self.move_label:SetMouseVisible(false)
    self:UpdateMoveLabel()

    self.background = Turbine.UI.Window()
    self.background:SetParent(self)
    self.background:SetPosition(0, MOVE_HEADER_HEIGHT)
    self.background:SetBackColor( Utils.ColorFix( self.data.color ) )
    self.background:SetSize(width, height)
    self.background:SetMouseVisible(true)

    self:ResetQuickslots()

    self:SetVisible(true)
    self.background:SetVisible(true)
    self.background:SetOpacity(self.data.opacity)
    self.move_header:SetVisible(false)


end

function QuickslotWindow:UpdateMoveLabel()

    self.move_label:SetText("<" .. self.index .. "> left: " .. self:GetLeft() .. " top: " .. self:GetTop())

end


function QuickslotWindow:MoveBy( dx, dy )

    local x, y = self:GetPosition()

    self:MoveTo( x + dx, y + dy )

end


-- the single writer of position, and therefore the single clamp site. the
-- clamp uses the whole window including the move header, so a bar can never
-- end up with its handle off the screen edge and no way to grab it back.
function QuickslotWindow:MoveTo( x, y )

    local width, height = Utils.WindowSize( self.data )

    x, y = Utils.ClampToScreen( x, y, width, height )

    self.data.left = x
    self.data.top = y

    self:SetPosition( x, y )
    self:UpdateMoveLabel()
    self:RefreshGapFrame()

end


-- put the gap frame back around the bar's current rect. called from MoveTo, so
-- it tracks a drag for free - MoveTo is the single writer of position - and from
-- Move(), /tbd gap and anything else that changes the gap or the bar's size.
--
-- move mode is read off the cluster rather than mirrored into a field here: the
-- cluster is where the flag lives, and a second copy would be one more thing to
-- keep in step on a Reload.
function QuickslotWindow:RefreshGapFrame()

    self.gap_frame:Apply( self.data, self.cluster ~= nil and self.cluster.moving == true )

end


function QuickslotWindow:SetSelected( state )

    self.selected = state

    if state then
        self.move_header:SetBackColor(MOVE_HEADER_COLOR_SELECTED)
    else
        self.move_header:SetBackColor(MOVE_HEADER_COLOR)
    end

end


-- the only caller of SetShortcut, so the one rule that matters about it lives in
-- one place: a blank slot is an Undefined shortcut, never nil. the shared
-- Turbine library monkey patches Quickslot:SetShortcut to call
-- SetVisible(value) with the shortcut *object*, so nil would hide the slot for
-- good (Turbine/UI/Lotro/Quickslot.lua, reached via Main.lua's
-- import "Turbine.UI.Lotro"). an Undefined shortcut is still a table, so truthy.
--
-- the guard flag lives on the slot, not the window, so reverting one slot does
-- not mute its neighbours - the slot already carries index and window, so
-- per-slot state has precedent here. the pcall is what guarantees the flag comes
-- back off: Shortcut() and SetShortcut can both throw on an entry this character
-- can no longer resolve, and a flag left set would turn that slot into one that
-- silently never saves again for the rest of the session. PrimePlugins pcalls
-- the same call in SkillBarQuickslots.lua and PrimeUIQuickSlot.lua.
function QuickslotWindow:ApplyShortcut( quickslot, entry )

    quickslot.restoring = true

    pcall( function()

        if entry == nil then
            quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined, "" ) )
        else
            quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( entry.Type, entry.Data ) )
        end

    end )

    -- outside the pcall, so a SetShortcut that throws cannot leave the slot at
    -- the wrong size
    self:ApplySlotSize( quickslot )

    quickslot.restoring = false

end


-- render this slot at the bar's scale.
--
-- SetSize alone gives a big hit box around art that is still 36px: the icon
-- only scales under stretch mode 1, and the api is explicit that the control
-- must be at the image's original size *before* the mode is assigned, because
-- that is the size everything afterwards is measured against. the other modes
-- are all dead ends - 2 and 4 stop the control receiving mouse events at all,
-- which would kill the click that fires the skill, and 0 and 3 crop instead of
-- scaling. primeplugins ships a 0.5x-3x quickslot scale slider built on exactly
-- this (RaidTools/PrimeUITools/SkillBarQuickslots.lua:170-182).
--
-- the bounce through the native size is mandatory, not tidiness. lotro drops a
-- setter whose value has not changed - the same trap behind ForceZOrder and
-- ForceOpacity elsewhere - so on a re-apply both SetStretchMode(1) and
-- SetSize(target) would be silent no-ops and the art would never come back.
-- moving the size to native first makes both writes real.
--
-- at scale 1 this returns untouched: SlotArt is 35, which is already the native
-- size, so an unscaled bar never enters stretch mode at all and its slots keep
-- whatever size the client gives them.
function QuickslotWindow:ApplySlotSize( quickslot )

    if Utils.ScaleOf( self.data ) == 1 then
        return
    end

    -- a slot that has never been laid out can report 0, and 0 as the reference
    -- size would make the stretch meaningless. fall back to the stock template
    -- size - QS_SIZE is that plus its gutter pixel - rather than giving up,
    -- because giving up here looks exactly like "scaling does not work".
    local native_width = tonumber( quickslot.native_width ) or 0
    local native_height = tonumber( quickslot.native_height ) or 0

    if native_width <= 0 then
        native_width = QS_SIZE - FRAME
    end

    if native_height <= 0 then
        native_height = QS_SIZE - FRAME
    end

    -- scaled straight off the stock 35, not derived from the rounded pitch, so
    -- the art lands on an exact multiple of its own native size
    local target = Utils.SlotArt( self.data )

    quickslot:SetSize( native_width, native_height )
    quickslot:SetStretchMode( 1 )
    quickslot:SetSize( target, target )

end


-- one handler for every way a slot's contents can change from the outside.
-- ShortcutChanged's args table is empty, so the new state has to be read back
-- off the sender.
--
-- note what this does *not* see: a plugin quickslot is a copy source, so
-- dragging a shortcut off one - or onto another slot - leaves the original in
-- place and fires nothing at all (measured in game 2026-11-19). there is no
-- drag-off gesture to hook. clearing is therefore plugin driven, via ClearSlots
-- and /tbd clear, and the empty branch below is only reached if some client
-- really does empty a slot behind our back.
--
-- the lock is a revert, not a refusal: SetAllowDrop(false) does not stop the
-- game putting a dropped shortcut into a quickslot (confirmed in Bovven and
-- abandoned in three PrimePlugins files), and there is no veto flag on
-- DragEnter/DragStart. so the drop lands and we put the old shortcut straight
-- back, which is what PrimePlugins' own locked skill bars do. the upside over a
-- mouse eating overlay is that clicking the slot still fires the skill.
function QuickslotWindow:OnShortcutChanged( quickslot )

    -- our own SetShortcut fires this event again
    if quickslot.restoring then
        return
    end

    -- the game latches a shortcut's art to the slot's geometry at the moment it
    -- is assigned, so a drop puts the icon back at native size. re-stretch
    -- before anything else here, including the SameShortcut early return below:
    -- dropping the skill a slot already holds changes nothing we save, but it
    -- still perturbs the art. primeplugins re-applies from its own
    -- ShortcutChanged handler for the same reason (PrimeUIQuickSlot.lua:108-113).
    self:ApplySlotSize( quickslot )

    local saved = self.data.quickslots[ quickslot.index ]
    local shortcut_type, shortcut_data = SlotFields( quickslot )

    -- nothing actually moved. this backs up the restoring flag and is the part
    -- that still holds if the client ever delivers the event a frame late rather
    -- than inside SetShortcut: a revert leaves the slot equal to the save, so
    -- the follow up event dies here and the recursion is finite by construction
    -- rather than by one boolean. it also stops a drop of the same skill onto
    -- the slot it already occupies rewriting the savefile.
    if SameShortcut( saved, shortcut_type, shortcut_data ) then
        return
    end

    if self.locked then

        -- saved == nil blanks the slot: the restore target for a locked empty
        -- slot is an Undefined shortcut, never nil
        self:ApplyShortcut( quickslot, saved )

        return

    end

    if shortcut_type == nil then
        -- dragged away. the entry is removed rather than stored as an Undefined
        -- one, because CreateQuickslots restores every non nil entry and would
        -- hand a stored Undefined back to SetShortcut on every rebuild.
        self.data.quickslots[ quickslot.index ] = nil
    else
        self.data.quickslots[ quickslot.index ] = { Type = shortcut_type, Data = shortcut_data }
    end

    Save()

end


-- empty one slot, or every slot on this bar when slot_index is nil. returns how
-- many slots actually held something.
--
-- the saved entry is removed by hand rather than left to OnShortcutChanged:
-- ApplyShortcut raises the restoring guard, so our own write is deliberately
-- invisible to the handler. the caller does the Save().
function QuickslotWindow:ClearSlots( slot_index )

    local cleared = 0

    for i, quickslot in ipairs(self.quickslots) do

        if slot_index == nil or i == slot_index then

            if self.data.quickslots[i] ~= nil then
                cleared = cleared + 1
            end

            self.data.quickslots[i] = nil

            self:ApplyShortcut( quickslot, nil )

        end

    end

    return cleared

end


function QuickslotWindow:Move( state )

    self.move_header:SetVisible(state)

    -- after the header, and reading the cluster's flag rather than `state`,
    -- because Cluster:Move sets that flag before it calls round the windows -
    -- so the two always agree and there is one source of truth
    self:RefreshGapFrame()

end

-- the handler consults self.locked at call time, so locking is just a flag now -
-- no swapping handlers in and out, which is what made the old lock a save
-- suppressor rather than a lock
function QuickslotWindow:SetLocked( state )

    self.locked = state

end


function QuickslotWindow:ResetQuickslots()

    self:ClearQuickslots()
    self:CreateQuickslots()

end


function QuickslotWindow:ClearQuickslots()
    
    for key, quickslot in ipairs(self.quickslots) do

        -- severed as well as unparented: the handler closes over this window and
        -- mutates its data table, so a reparented orphan must not still be able
        -- to fire into it
        quickslot.ShortcutChanged = nil

        quickslot:SetVisible(false)
        quickslot:SetMouseVisible(false)
        quickslot:SetParent(nil)

    end

    self.quickslots = {}

end


function QuickslotWindow:CreateQuickslots()

    local pitch = Utils.SlotPitch( self.data )
    local lead = Utils.SlotLead( self.data )

    for i=1, self.data.height, 1 do

        for j=1, self.data.width, 1 do

            -- the grid starts at the small SlotLead while BarRect ends at the
            -- larger SlotEdge. deliberately uneven: the quickslot insets its own
            -- art from the top left, so this is what renders as an even border
            local left = lead + ( (j - 1) * pitch )
            local top = lead + ( (i - 1) * pitch )
            local index = #self.quickslots + 1

            self.quickslots[index] = Turbine.UI.Lotro.Quickslot()
            self.quickslots[index]:SetParent(self.background)
            self.quickslots[index]:SetPosition(left, top)
            self.quickslots[index].index = index
            self.quickslots[index].window = self

            -- the slot's size before anything has resized it, stashed on the
            -- slot the same way index and window are. read rather than
            -- hardcoded as 35, and captured here because ApplySlotSize below
            -- needs it and every later call would read back a scaled size.
            self.quickslots[index].native_width,
            self.quickslots[index].native_height = self.quickslots[index]:GetSize()

            -- applied even when there is nothing saved, so a slot that was
            -- cleared comes back explicitly blank after a rebuild.
            --
            -- deliberately before ShortcutChanged is attached below, so a
            -- rebuild does not fire one event and one Save() per slot. belt and
            -- braces now that ApplyShortcut sets the guard itself, but the next
            -- person to tidy the order needs to know why it is this way.
            self:ApplyShortcut( self.quickslots[index], self.data.quickslots[index] )

            self.quickslots[index].ShortcutChanged = function (sender, args)

                self:OnShortcutChanged( sender )

            end

        end

    end
    
end

function QuickslotWindow:Closing()

    -- the slots hold a ShortcutChanged closure over this window, so an orphan
    -- left parented to a closed background could still fire into a stale
    -- data table on the next rebuild
    self:ClearQuickslots()

    self:SetVisible(false)
    self.background:SetVisible(false)
    self.move_header:SetVisible(false)

    -- the frame's bands are top level windows, so nothing tears them down with
    -- this one. a Reload closes every window and builds new ones, which without
    -- this would leave a magenta frame on screen around nothing.
    self.gap_frame:Close()

    self.background:Close()
    self.move_header:Close()

end
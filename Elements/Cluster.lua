
--[[
    class to combine multiple qickslotwindows

    data:
    - list of qickslotwindows

]]

-- bounding box of a list of windows, from their visible bar rects
local function MembersBounds( members )

    local left, top, right, bottom

    for i, window in ipairs(members) do

        local x, y, w, h = Utils.BarRect( window.data )

        if left   == nil or x     < left   then left   = x     end
        if top    == nil or y     < top    then top    = y     end
        if right  == nil or x + w > right  then right  = x + w end
        if bottom == nil or y + h > bottom then bottom = y + h end

    end

    return left, top, right, bottom

end


-- a snap candidate is an explicit { moving edge, target position, is screen
-- centre } triple rather than a loose edge list crossed with a target list,
-- because the gap only applies to *adjacency* (my left edge against your right
-- edge) and never to *alignment* (my left edge against your left edge).
--
-- returns the smallest correction within SNAP_DISTANCE, or 0 when there is
-- none, plus whether the winner was a screen centre line so the caller can
-- light the matching guide. candidates are walked in order and compared with a
-- strict <, so an earlier candidate wins a tie - the screen centre ones are
-- added first for exactly that reason.
local function SnapCandidates( candidates )

    local best = 0
    local best_distance = nil
    local best_screen = false

    for i, candidate in ipairs(candidates) do

        local correction = candidate[2] - candidate[1]
        local distance = math.abs(correction)

        if distance <= SNAP_DISTANCE and ( best_distance == nil or distance < best_distance ) then
            best = correction
            best_distance = distance
            best_screen = ( candidate[3] == true )
        end

    end

    return best, best_screen

end


Cluster = class()

function Cluster:Constructor(data)

    self.data = data
    self.moving = false

    -- read from the save, not defaulted to false: a trait line swap throws this
    -- cluster away and builds a new one (LayoutChanges.lua), so the lock has to
    -- live in Data to survive one. seeded before CreateWindows so the bars are
    -- born locked.
    self.locked = ( Data.locked == true )

    -- set of selected window indices, runtime only, never saved
    self.selection = {}

    self.windows = {}

    self.guides = Guides()

    self:CreateWindows()

end

function Cluster:Move()

    self.moving = not(self.moving)

    -- the handles carry the selection highlight, so leaving move mode with a
    -- selection still set would leave it invisible
    if not self.moving then
        self:ClearSelection()
    end

    -- there is no resolution change event in the api, so the guides re-centre
    -- on the move mode toggle instead
    self.guides:Refresh()
    self.guides:Show(self.moving)

    for index, window in pairs(self.windows) do
        window:Move(self.moving)
    end

end

function Cluster:Lock()

    self.locked = not(self.locked)
    Data.locked = self.locked

    for index, window in pairs(self.windows) do
        window:SetLocked(self.locked)
    end

    Save()

    if self.locked then
        Turbine.Shell.WriteLine("Quickslots locked - skills can no longer be added or removed.")
    else
        Turbine.Shell.WriteLine("Quickslots unlocked.")
    end

end

-- empty quickslots. window_index nil means every bar on this trait line,
-- slot_index nil means every slot on the bar. returns the number of slots that
-- actually held something, or nil when the lock refused.
--
-- the lock refuses this on purpose: a command that walked straight through a
-- lock would make the lock mean "except when you ask nicely", which is not a
-- lock. the message points at /tbd lock so it is a one step recovery.
function Cluster:ClearSlots( window_index, slot_index )

    if self.locked then
        Turbine.Shell.WriteLine("Quickslots are locked - run /tbd lock first.")
        return nil
    end

    local cleared = 0

    for index, window in pairs(self.windows) do
        if window_index == nil or index == window_index then
            cleared = cleared + window:ClearSlots( slot_index )
        end
    end

    if cleared > 0 then
        Save()
    end

    return cleared

end


function Cluster:Reload()

    self:CloseWindows()
    self:CreateWindows()

    self.guides:Refresh()

    -- drop any selected index the rebuilt window list no longer has
    for index, selected in pairs(self.selection) do
        if self.windows[index] == nil then
            self.selection[index] = nil
        end
    end

    self:ApplySelection()

    -- move mode is re-applied but the lock is not, and the asymmetry is
    -- deliberate: QuickslotWindow's constructor unconditionally hides the move
    -- header, so `moving` genuinely needs putting back, whereas it reads
    -- cluster.locked for itself and is born with the right lock. a second
    -- mechanism for the lock would only ever lock, never unlock.
    if self.moving then
        for index, window in pairs(self.windows) do
            window:Move(true)
        end
    end

end

function Cluster:CreateWindows()

    for index, window_data in ipairs(self.data) do

        self.windows[#self.windows +1] = QuickslotWindow(window_data, index, self)

    end

end


function Cluster:IsSelected( index )

    return self.selection[index] == true

end


function Cluster:SelectionCount()

    local count = 0

    for index, selected in pairs(self.selection) do
        count = count + 1
    end

    return count

end


function Cluster:SetSelected( index, state )

    if self.windows[index] == nil then
        return
    end

    if state then
        self.selection[index] = true
    else
        self.selection[index] = nil
    end

    self.windows[index]:SetSelected(state)

end


function Cluster:ToggleSelected( index )

    self:SetSelected( index, not self:IsSelected(index) )

end


function Cluster:ClearSelection()

    self.selection = {}

    self:ApplySelection()

end


function Cluster:SelectAll()

    for index, window in pairs(self.windows) do
        self:SetSelected(index, true)
    end

end


function Cluster:ApplySelection()

    for index, window in pairs(self.windows) do
        window:SetSelected( self:IsSelected(index) )
    end

end


function Cluster:SelectedWindows()

    local list = {}

    for index, window in pairs(self.windows) do
        if self:IsSelected(index) then
            list[#list + 1] = window
        end
    end

    return list

end


-- one drag event, fanned out: if the grabbed bar is selected the whole
-- selection moves by the same delta, otherwise only the grabbed bar moves
function Cluster:DragBy( window, dx, dy )

    if dx == 0 and dy == 0 then
        return
    end

    local members = { window }

    if self:IsSelected(window.index) then
        members = self:SelectedWindows()
    end

    dx, dy = self:SnapDelta( members, dx, dy )

    for i, member in ipairs(members) do
        member:MoveBy(dx, dy)
    end

end


-- adjust one drag delta so the moving group lands on a snap target and stays
-- on screen.
--
-- this works because the delta handed to DragBy is always the gap between
-- where the cursor says the group should be and where it actually is, not a
-- running total. a correction applied here therefore reappears in the next
-- event's delta, which is what makes the group stick to a line while the
-- cursor stays close and release cleanly once it does not.
function Cluster:SnapDelta( members, dx, dy )

    local left, top, right, bottom = MembersBounds( members )

    left   = left   + dx
    right  = right  + dx
    top    = top    + dy
    bottom = bottom + dy

    local snapped_x = false
    local snapped_y = false

    if not Utils.IsSnapOverrideDown() then

        local screen_width, screen_height = Turbine.UI.Display.GetSize()

        local centre_x = math.floor( screen_width / 2 )
        local centre_y = math.floor( screen_height / 2 )

        local group_centre_x = left + math.floor( ( right - left ) / 2 )
        local group_centre_y = top  + math.floor( ( bottom - top ) / 2 )

        local gap = Data.gap or 0

        -- the screen centre candidates go first so they win a tie against a bar
        local candidates_x = {
            { group_centre_x, centre_x, true },
            { left,           centre_x, true },
            { right,          centre_x, true },
        }

        local candidates_y = {
            { group_centre_y, centre_y, true },
            { top,            centre_y, true },
            { bottom,         centre_y, true },
        }

        -- excluded by membership in the moving group, not by selection: a bar
        -- being dragged on its own must still snap to the selected ones
        local in_group = {}

        for i, member in ipairs(members) do
            in_group[member.index] = true
        end

        for index, window in pairs(self.windows) do
            if not in_group[index] then

                local x, y, w, h = Utils.BarRect( window.data )

                -- adjacency: sit beside the bar, gap pixels clear of it
                candidates_x[#candidates_x + 1] = { left,  x + w + gap }
                candidates_x[#candidates_x + 1] = { right, x - gap }

                candidates_y[#candidates_y + 1] = { top,    y + h + gap }
                candidates_y[#candidates_y + 1] = { bottom, y - gap }

                -- alignment: share an edge or a centre line, never a gap
                candidates_x[#candidates_x + 1] = { left,           x }
                candidates_x[#candidates_x + 1] = { right,          x + w }
                candidates_x[#candidates_x + 1] = { group_centre_x, x + math.floor( w / 2 ) }

                candidates_y[#candidates_y + 1] = { top,            y }
                candidates_y[#candidates_y + 1] = { bottom,         y + h }
                candidates_y[#candidates_y + 1] = { group_centre_y, y + math.floor( h / 2 ) }

            end
        end

        local cx, screen_x = SnapCandidates( candidates_x )
        local cy, screen_y = SnapCandidates( candidates_y )

        dx = dx + cx
        dy = dy + cy

        left   = left   + cx
        right  = right  + cx
        top    = top    + cy
        bottom = bottom + cy

        snapped_x = screen_x
        snapped_y = screen_y

    end

    self.guides:SetActive( snapped_x, snapped_y )

    -- clamp the whole group at once rather than letting each bar clamp itself,
    -- which would squash the group's relative offsets as soon as one member
    -- reached an edge. the group's window box reaches MOVE_HEADER_HEIGHT above
    -- the topmost bar.
    local window_left   = left
    local window_top    = top - MOVE_HEADER_HEIGHT
    local window_width  = right - left
    local window_height = bottom - top + MOVE_HEADER_HEIGHT

    local clamped_left, clamped_top =
        Utils.ClampToScreen( window_left, window_top, window_width, window_height )

    dx = dx + ( clamped_left - window_left )
    dy = dy + ( clamped_top - window_top )

    return dx, dy

end


function Cluster:CloseWindows()

    for index, window in pairs(self.windows) do
        window:Close()
    end

    self.windows = {}

end


function Cluster:Close()

    self:CloseWindows()

    self.guides:Close()

end

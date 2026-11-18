
--[[
    class to combine multiple qickslotwindows

    data:
    - list of qickslotwindows

]]

Cluster = class()

function Cluster:Constructor(data)

    self.data = data
    self.moving = false
    self.locked = false

    -- set of selected window indices, runtime only, never saved
    self.selection = {}

    self.windows = {}

    self:CreateWindows()

end

function Cluster:Move()

    self.moving = not(self.moving)

    -- the handles carry the selection highlight, so leaving move mode with a
    -- selection still set would leave it invisible
    if not self.moving then
        self:ClearSelection()
    end

    for index, window in pairs(self.windows) do
        window:Move(self.moving)
    end

end

function Cluster:Lock()

    self.locked = not(self.locked)

    for index, window in pairs(self.windows) do
        window:SetLocked(self.locked)
    end

    if self.locked then
        Turbine.Shell.WriteLine("Quickslots locked.")
    else
        Turbine.Shell.WriteLine("Quickslots unlocked.")
    end

end

function Cluster:Reload()

    self:CloseWindows()
    self:CreateWindows()

    -- drop any selected index the rebuilt window list no longer has
    for index, selected in pairs(self.selection) do
        if self.windows[index] == nil then
            self.selection[index] = nil
        end
    end

    self:ApplySelection()

    if self.moving then
        for index, window in pairs(self.windows) do
            window:Move(true)
        end
    end

    if self.locked then
        for index, window in pairs(self.windows) do
            window:SetLocked(true)
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


-- one drag event, fanned out: if the grabbed bar is selected the whole
-- selection moves by the same delta, otherwise only the grabbed bar moves
function Cluster:DragBy( window, dx, dy )

    if dx == 0 and dy == 0 then
        return
    end

    if not self:IsSelected(window.index) then
        window:MoveBy(dx, dy)
        return
    end

    for index, other in pairs(self.windows) do
        if self:IsSelected(index) then
            other:MoveBy(dx, dy)
        end
    end

end


function Cluster:CloseWindows()

    for index, window in pairs(self.windows) do
        window:Close()
    end

    self.windows = {}

end


function Cluster:Close()

    self:CloseWindows()

end

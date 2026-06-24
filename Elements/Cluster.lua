
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

    self.windows = {}

    self:CreateWindows()

end

function Cluster:Move()

    self.moving = not(self.moving)

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

        self.windows[#self.windows +1] = QuickslotWindow(window_data, index)

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

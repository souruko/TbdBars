
--[[
    class to combine multiple qickslotwindows 

    data:
    - list of qickslotwindows

]]

Cluster = class()

function Cluster:Constructor(data)

    self.data = data
    self.moving = false

    self.windows = {}

    self:CreateWindows()

end

function Cluster:Move()

    self.moving = not(self.moving)

    for index, window in pairs(self.windows) do
        window:Move(self.moving)
    end

end


function Cluster:CreateWindows()

    for index, window_data in ipairs(self.data) do

        self.windows[#self.windows +1] = QuickslotWindow(window_data, index)

    end

end


function Cluster:CloseWindows()

end


function Cluster:Close()

    self:CloseWindows()

end
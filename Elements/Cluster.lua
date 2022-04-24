
--[[
    class to combine multiple qickslotwindows 

    data:
    - list of qickslotwindows

]]

Cluster = class()

function Cluster:Constructor(data)

    self.data = data

    self.windows = {}

    self:CreateWindows()

end


function Cluster:CreateWindows()

    for index, window_data in ipairs(self.data) do

        self.windows[#self.windows +1] = QuickslotWindow(window_data)

    end
    
end


function Cluster:CloseWindows()
    
end
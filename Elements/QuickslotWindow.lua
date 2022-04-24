
--[[
    
    data:

    - left
    - top
    - width (in qickslot count)
    - height (in qickslot count)
    - background color

]]

QuickslotWindow = class( Turbine.UI.Window )

function QuickslotWindow:Constructor(data)
    Turbine.UI.Window.Constructor( self )

    self.data = data
    self.quickslots = {}


    local width = ( QS_SIZE * self.data.width) + ( FRAME * 4 )
    local height = ( QS_SIZE * self.data.height) + ( FRAME * 4 )
    self:SetPosition(self.data.left, self.data.top)
    self:SetBackColor(self.data.color)
    self:SetSize(width, height)

    self:ResetQuickslots()

    self:SetVisible(true)

end


function QuickslotWindow:ResetQuickslots()

    self:ClearQuickslots()
    self:CreateQuickslots()

end

function QuickslotWindow:ClearQuickslots()
    
    for key, quickslot in ipairs(self.quickslots) do

        quickslot:SetVisible(false)
        quickslot:SetMouseVisible(false)
        quickslot:SetParent(nil)

    end

    self.quickslots = {}

end


function QuickslotWindow:CreateQuickslots()

    for i=1, self.data.height, 1 do

        for j=1, self.data.width, 1 do

            local left = FRAME + ( (j - 1) * QS_SIZE )
            local top = FRAME + ( (i - 1) * QS_SIZE )

            self.quickslots[#self.quickslots + 1] = Turbine.UI.Lotro.Quickslot()
            self.quickslots[#self.quickslots]:SetParent(self)
            self.quickslots[#self.quickslots]:SetPosition(left, top)
            
            if self.data.quickslots[#self.quickslots] ~= nil then
                self.quickslots[#self.quickslots]:SetShortcut( Turbine.UI.Lotro.Shortcut( self.data.quickslots[#self.quickslots].Type, self.data.quickslots[#self.quickslots].Data ) )
            end

        end

    end
    
end
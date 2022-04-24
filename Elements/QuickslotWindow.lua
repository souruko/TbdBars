
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


end
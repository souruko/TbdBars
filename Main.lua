import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

import "TbdBars.Globals"
import "TbdBars.Utils"
import "TbdBars.Elements"


-------------------------------------------------------------------
-- to be deleted
-------------------------------------------------------------------
local data = {}

data[RED] = {}

data[RED][1] = {}
data[RED][1].left = 500
data[RED][1].top = 500
data[RED][1].width = 10
data[RED][1].height = 2
data[RED][1].color = Turbine.UI.Color.Black
data[RED][1].quickslots = {}

for i = 1, 20 do

    data[RED][1].quickslots[i] = {}
    data[RED][1].quickslots[i].Type = Turbine.UI.Lotro.ShortcutType.Skill
    data[RED][1].quickslots[i].Data = "0x700031FA"

end

data[RED][2] = {}
data[RED][2].left = 1000
data[RED][2].top = 600
data[RED][2].width = 5
data[RED][2].height = 3
data[RED][2].color = Turbine.UI.Color.Red
data[RED][2].quickslots = {}

for i = 1, 20 do

    data[RED][2].quickslots[i] = {}
    -- data[RED][2].quickslots[i].Type = Turbine.UI.Lotro.ShortcutType.Skill
    -- data[RED][2].quickslots[i].Data = "0x700031FA"

end



data[YELLOW] = {}

data[YELLOW][1] = {}
data[YELLOW][1].left = 500
data[YELLOW][1].top = 500
data[YELLOW][1].width = 10
data[YELLOW][1].height = 2
data[YELLOW][1].color = Turbine.UI.Color.Blue


data[YELLOW][2] = {}
data[YELLOW][2].left = 1000
data[YELLOW][2].top = 600
data[YELLOW][2].width = 5
data[YELLOW][2].height = 3
data[YELLOW][2].color = Turbine.UI.Color.Orange

data[BLUE] = {}

data.activ = RED
-------------------------------------------------------------------
-- to be deleted
-------------------------------------------------------------------

-- load up


Activ_Cluster = Elements.Cluster( data[data.activ] )
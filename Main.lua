import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

import "TbdBars.DataFunctions"
import "TbdBars.Globals"
import "TbdBars.Utils"
import "TbdBars.Elements"


-------------------------------------------------------------------
-- to be deleted
-------------------------------------------------------------------
Data = {}

Data[TRAIT_LINE.Red] = {}

Data[TRAIT_LINE.Red][1] = {}
Data[TRAIT_LINE.Red][1].name = "ghj"
Data[TRAIT_LINE.Red][1].left = 500
Data[TRAIT_LINE.Red][1].top = 500
Data[TRAIT_LINE.Red][1].width = 10
Data[TRAIT_LINE.Red][1].height = 2
Data[TRAIT_LINE.Red][1].color = Turbine.UI.Color.Black
Data[TRAIT_LINE.Red][1].quickslots = {}
Data[TRAIT_LINE.Red][1].opacity = 1

for i = 1, 20 do

    Data[TRAIT_LINE.Red][1].quickslots[i] = {}
    Data[TRAIT_LINE.Red][1].quickslots[i].Type = Turbine.UI.Lotro.ShortcutType.Skill
    Data[TRAIT_LINE.Red][1].quickslots[i].Data = "0x700031FA"

end

Data[TRAIT_LINE.Red][2] = {}
Data[TRAIT_LINE.Red][2].name = "fghj"
Data[TRAIT_LINE.Red][2].left = 1000
Data[TRAIT_LINE.Red][2].top = 600
Data[TRAIT_LINE.Red][2].width = 5
Data[TRAIT_LINE.Red][2].height = 3
Data[TRAIT_LINE.Red][2].color = Turbine.UI.Color.Red
Data[TRAIT_LINE.Red][2].quickslots = {}
Data[TRAIT_LINE.Red][2].opacity = 1

for i = 1, 20 do

    Data[TRAIT_LINE.Red][2].quickslots[i] = {}

end



Data[TRAIT_LINE.Yellow] = {}

Data[TRAIT_LINE.Yellow][1] = {}
Data[TRAIT_LINE.Yellow][1].name = "gzhj"
Data[TRAIT_LINE.Yellow][1].left = 500
Data[TRAIT_LINE.Yellow][1].top = 1000
Data[TRAIT_LINE.Yellow][1].width = 10
Data[TRAIT_LINE.Yellow][1].height = 2
Data[TRAIT_LINE.Yellow][1].color = Turbine.UI.Color.Blue
Data[TRAIT_LINE.Yellow][1].opacity = 1
Data[TRAIT_LINE.Yellow][1].quickslots = {}

for i = 1, 20 do

    Data[TRAIT_LINE.Yellow][1].quickslots[i] = {}

end

Data[TRAIT_LINE.Yellow][2] = {}
Data[TRAIT_LINE.Yellow][2].name = "1000"
Data[TRAIT_LINE.Yellow][2].left = 1000
Data[TRAIT_LINE.Yellow][2].top = 1000
Data[TRAIT_LINE.Yellow][2].width = 5
Data[TRAIT_LINE.Yellow][2].height = 3
Data[TRAIT_LINE.Yellow][2].color = Turbine.UI.Color.Orange
Data[TRAIT_LINE.Yellow][2].opacity = 1
Data[TRAIT_LINE.Yellow][2].quickslots = {}

for i = 1, 20 do

    Data[TRAIT_LINE.Yellow][2].quickslots[i] = {}

end

Data[TRAIT_LINE.Blue] = {}

Data.activ = TRAIT_LINE.Red
-------------------------------------------------------------------
-- to be deleted
-------------------------------------------------------------------



Activ_Cluster = Elements.Cluster( Data[Data.activ] )
import "TbdBars.TraitlineChange"
import "TbdBars.ChatCommands"

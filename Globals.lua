LOCALPLAYER = Turbine.Gameplay.LocalPlayer.GetInstance()
LP_CLASS = LOCALPLAYER:GetClass()

TRAIT_LINE ={}
TRAIT_LINE.Blue = 1
TRAIT_LINE.Red = 2
TRAIT_LINE.Yellow = 3

Activ_Cluster = nil

FRAME = 1
QS_SIZE = 35

ClassSpecializationString = "You have acquired the Class Specialization Bonus Trait:"

ClassStrings = {}

ClassStrings[Turbine.Gameplay.Class.Burglar] = {}
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Red] = "The Quiet Knife."
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Yellow] = "The Mischief.maker"
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Blue] = "The Gambler"
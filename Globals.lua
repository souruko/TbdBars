Data = nil

Layout = nil

-- find used client G.language
Locale = 1
if Turbine.Shell.IsCommand("hilfe") then
    Locale = 2
elseif Turbine.Shell.IsCommand("aide") then
    Locale = 3
end

-- so i can use locale as a number
LANGUAGE = {}
LANGUAGE.English = 1
LANGUAGE.German  = 2
LANGUAGE.French  = 3

LOCALPLAYER = Turbine.Gameplay.LocalPlayer.GetInstance()
LP_CLASS = LOCALPLAYER:GetClass()

TRAIT_LINE ={}
TRAIT_LINE.Blue = 1
TRAIT_LINE.Red = 2
TRAIT_LINE.Yellow = 3

Activ_Cluster = nil

FRAME = 1
QS_SIZE = 36

ClassSpecializationString = "You have acquired the Class Specialization Bonus Trait:"

ClassStrings = {}

ClassStrings[Turbine.Gameplay.Class.Burglar] = {}
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Red]    = "The Quiet Knife"
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Yellow] = "The Mischief.maker"
ClassStrings[Turbine.Gameplay.Class.Burglar][TRAIT_LINE.Blue]   = "The Gambler"

ClassStrings[Turbine.Gameplay.Class.Captain] = {}
ClassStrings[Turbine.Gameplay.Class.Captain][TRAIT_LINE.Red]    = "Lead the Charge"
ClassStrings[Turbine.Gameplay.Class.Captain][TRAIT_LINE.Yellow] = "Leader of Men"
ClassStrings[Turbine.Gameplay.Class.Captain][TRAIT_LINE.Blue]   = "Hands of Healing"

ClassStrings[Turbine.Gameplay.Class.Beorning] = {}
ClassStrings[Turbine.Gameplay.Class.Beorning][TRAIT_LINE.Red]   = "The Claw"
ClassStrings[Turbine.Gameplay.Class.Beorning][TRAIT_LINE.Yellow]= "The Roar"
ClassStrings[Turbine.Gameplay.Class.Beorning][TRAIT_LINE.Blue]  = "The Hide"

ClassStrings[Turbine.Gameplay.Class.Brawler] = {}
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Red]    = ""
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Yellow] = ""
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Blue]   = ""

ClassStrings[Turbine.Gameplay.Class.Champion] = {}
ClassStrings[Turbine.Gameplay.Class.Champion][TRAIT_LINE.Red]   = "The Berserker"
ClassStrings[Turbine.Gameplay.Class.Champion][TRAIT_LINE.Yellow]= "The Deadly Storm"
ClassStrings[Turbine.Gameplay.Class.Champion][TRAIT_LINE.Blue]  = "The Martial Champion"

ClassStrings[Turbine.Gameplay.Class.Guardian] = {}
ClassStrings[Turbine.Gameplay.Class.Guardian][TRAIT_LINE.Red]   = "The Keen Blade"
ClassStrings[Turbine.Gameplay.Class.Guardian][TRAIT_LINE.Yellow]= "The Fighter of Shadow"
ClassStrings[Turbine.Gameplay.Class.Guardian][TRAIT_LINE.Blue]  = "The Defender of the Free"

ClassStrings[Turbine.Gameplay.Class.Hunter] = {}
ClassStrings[Turbine.Gameplay.Class.Hunter][TRAIT_LINE.Red]     = "Bowmaster"
ClassStrings[Turbine.Gameplay.Class.Hunter][TRAIT_LINE.Yellow]  = "Trapper of Foes"
ClassStrings[Turbine.Gameplay.Class.Hunter][TRAIT_LINE.Blue]    = "Huntsman"

ClassStrings[Turbine.Gameplay.Class.RuneKeeper] = {}
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Red]     = "Cleansing Flame"
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Yellow]  = "Solitary Thunder"
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Blue]    = "Benediction of Peace"

ClassStrings[Turbine.Gameplay.Class.Minstrel] = {}
ClassStrings[Turbine.Gameplay.Class.Minstrel][TRAIT_LINE.Red]   = "The Warrior.Skald"
ClassStrings[Turbine.Gameplay.Class.Minstrel][TRAIT_LINE.Yellow]= "The Protector of Song"
ClassStrings[Turbine.Gameplay.Class.Minstrel][TRAIT_LINE.Blue]  = "The Watcher of Resolve"

ClassStrings[Turbine.Gameplay.Class.LoreMaster] = {}
ClassStrings[Turbine.Gameplay.Class.LoreMaster][TRAIT_LINE.Red]     = "Master of Nature's Fury"
ClassStrings[Turbine.Gameplay.Class.LoreMaster][TRAIT_LINE.Yellow]  = "The Ancient Master"
ClassStrings[Turbine.Gameplay.Class.LoreMaster][TRAIT_LINE.Blue]    = "Keeper of Animals"

ClassStrings[Turbine.Gameplay.Class.Warden] = {}
ClassStrings[Turbine.Gameplay.Class.Warden][TRAIT_LINE.Red]     = "Recklessness"
ClassStrings[Turbine.Gameplay.Class.Warden][TRAIT_LINE.Yellow]  = "Assailment"
ClassStrings[Turbine.Gameplay.Class.Warden][TRAIT_LINE.Blue]    = "Determination"
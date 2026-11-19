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

-- a quickslot does not fill its own control. it draws its icon inset from the
-- TOP LEFT and flush to the bottom right: a 35px control carries 32px of art at
-- offset 3, trailing edge 0. measured in game 2026-11-19 by scaling a bar to 2x
-- and reading the pixels back - a 70px control drew 64px of art at offset 6, so
-- stretch mode scales the inset along with everything else.
--
-- this is the whole reason the layout maths is lop-sided. the border a player
-- sees on the left is the bar's own padding PLUS this inset, and on the right it
-- is the padding alone, so an even-looking bar needs uneven numbers. get this
-- wrong in the tidy direction and every bar gains a fat edge top left and a thin
-- one bottom right.
QS_ART_INSET = 3

-- how far /tbd scale may take a single bar. 0.5 is the floor primeplugins
-- ships on its own quickslot scale slider; 5 is headroom. the source icon art
-- is 32x32 inside a 35x35 template, so past about 3 it is a soft bilinear
-- upscale - usable, but do not expect it to look sharp.
SCALE_MIN = 0.5
SCALE_MAX = 5

-- move handle colours. never mutate these, Turbine.UI.Color.X is shared
-- process wide. cyan is picked over orange so it cannot read as "a slightly
-- different yellow", and it still keeps the handle's black label readable.
MOVE_HEADER_COLOR          = Turbine.UI.Color.Yellow
MOVE_HEADER_COLOR_SELECTED = Turbine.UI.Color.Cyan

MOVE_HEADER_WIDTH  = 200
MOVE_HEADER_HEIGHT = 20

-- how close an edge has to come to a target before it snaps, in pixels
SNAP_DISTANCE = 8

-- the guide lines are drawn over the game world, so a 1px line is hard to make
-- out against terrain. a bright edge around a darker core reads at any
-- brightness, which is what Gibberish3 settled on for its crosshair.
GUIDE_THICKNESS    = 4
GUIDE_COLOR        = MOVE_HEADER_COLOR_SELECTED
GUIDE_COLOR_ACTIVE = Turbine.UI.Color.White
GUIDE_COLOR_CORE   = Turbine.UI.Color(0.1, 0.1, 0.1)

-- the gap frame drawn around every bar in move mode: a band exactly Data.gap
-- pixels thick hugging the bar on all four sides, which is the ground a
-- neighbour will be held off by when it snaps alongside.
--
-- magenta because the three colours already in use are taken and have to stay
-- told apart: yellow is a handle, cyan a selected handle, white a live guide
-- line. and translucent because the top band lands in the same 20px strip as
-- the move handle - the handle has to stay readable through it, and a solid
-- band would read as a bar rather than as empty ground.
GAP_FRAME_COLOR   = Turbine.UI.Color(1, 0.2, 1)
GAP_FRAME_OPACITY = 0.45

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

ClassStrings[Turbine.Gameplay.Class.Mariner] = {}
ClassStrings[Turbine.Gameplay.Class.Mariner][TRAIT_LINE.Red]    = "The Duellist"
ClassStrings[Turbine.Gameplay.Class.Mariner][TRAIT_LINE.Yellow] = "The Rover"
ClassStrings[Turbine.Gameplay.Class.Mariner][TRAIT_LINE.Blue]   = "The Shanty.caller"

ClassStrings[Turbine.Gameplay.Class.Brawler] = {}
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Red]    = "The Fulcrum"
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Yellow] = "The Maelstrom"
ClassStrings[Turbine.Gameplay.Class.Brawler][TRAIT_LINE.Blue]   = "The Fundament"

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
ClassStrings[Turbine.Gameplay.Class.Hunter][TRAIT_LINE.Yellow]  = "The Trapper"
ClassStrings[Turbine.Gameplay.Class.Hunter][TRAIT_LINE.Blue]    = "Huntsman"

ClassStrings[Turbine.Gameplay.Class.RuneKeeper] = {}
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Red]     = "Cleansing Flame"
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Yellow]  = "Solitary Thunder"
ClassStrings[Turbine.Gameplay.Class.RuneKeeper][TRAIT_LINE.Blue]    = "Benedictions of Peace"

ClassStrings[Turbine.Gameplay.Class.Minstrel] = {}
ClassStrings[Turbine.Gameplay.Class.Minstrel][TRAIT_LINE.Red]   = "The Warrior.skald"
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
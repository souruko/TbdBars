-- fix color from savefile to Turbine.UI.Color
function ColorFix(color)
    if color == nil then
        return nil
    end
	-- A is optional (older saves and 3-value /tbd color have none).
	-- the four-argument constructor takes alpha FIRST: (a, r, g, b)
	if color.A ~= nil then
		return Turbine.UI.Color(color.A, color.R, color.G, color.B)
	end
	return Turbine.UI.Color(color.R, color.G, color.B)
end

-- true while the "add to selection" modifier is held.
-- mouse event args only carry Button/X/Y, so the key state comes from the
-- static Turbine.UI.Control query; args.Control is checked first in case a
-- client does pass it. swap IsControlKeyDown for IsShiftKeyDown here if the
-- client swallows ctrl+left-click over plugin ui.
function IsAddToSelectionDown( args )

    if args ~= nil and args.Control ~= nil and args.Control ~= false and args.Control ~= 0 then
        return true
    end

    local down = Turbine.UI.Control.IsControlKeyDown()

    return down ~= nil and down ~= false and down ~= 0

end

-- true while the "ignore snapping" modifier is held
function IsSnapOverrideDown()

    local down = Turbine.UI.Control.IsAltKeyDown()

    return down ~= nil and down ~= false and down ~= 0

end

-- the snap gap, as a whole number of pixels. the snap maths only ever added it
-- to something and so could live with whatever Data.gap happened to hold, but
-- SetSize is a real api call and will not take the string a german or french
-- client stores it as - hence one accessor for both callers. negatives and
-- fractions are the savefile being a text file a player can edit.
function GapSize()

    local gap = tonumber( Data.gap ) or 0

    if gap < 0 then
        return 0
    end

    return math.floor( gap )

end

-- a bar's scale factor. read lazily with a default rather than seeded into the
-- save, which is what makes old savefiles, old layout snapshots and a bar built
-- by LoadLayout all correct without a migration pass. tonumber because the DE/FR
-- client stores every number as a string, and clamped because the savefile is a
-- text file a player can edit.
function ScaleOf( data )

    local scale = tonumber( data.scale )

    if scale == nil then
        return 1
    end

    if scale < SCALE_MIN then
        return SCALE_MIN
    end

    if scale > SCALE_MAX then
        return SCALE_MAX
    end

    return scale

end

-- padding between the background's top left corner and the first slot CONTROL.
-- this is not what the player sees as the border - add SlotEdge's inset for
-- that - it is just where the grid starts.
function SlotLead( data )

    local lead = math.floor( ( FRAME * ScaleOf( data ) ) + 0.5 )

    if lead < FRAME then
        return FRAME
    end

    return lead

end

-- the border a player actually sees: the leading pad plus the quickslot's own
-- art inset (QS_ART_INSET, see Globals.lua). the same number serves as the
-- background's trailing margin, because the art is flush to its control's
-- bottom right and so needs no inset compensation there - and as the gap
-- between two neighbouring icons, which works out to the same thing. one value,
-- so the border and every gap between icons match at any scale.
function SlotEdge( data )

    return SlotLead( data ) + math.floor( ( QS_ART_INSET * ScaleOf( data ) ) + 0.5 )

end

-- drawn size of one slot. QS_SIZE is the grid step and FRAME the gutter inside
-- it, so QS_SIZE - FRAME is the stock size the client gives a quickslot, 35.
function SlotArt( data )

    return math.floor( ( ( QS_SIZE - FRAME ) * ScaleOf( data ) ) + 0.5 )

end

-- pixel pitch of one slot: its control plus one leading pad. rounded in
-- SlotArt/SlotLead and then only ever added, so the grid and the background
-- behind it cannot drift apart - rounding the pitch itself instead leaves the
-- last column a pixel out of its background. at scale 1 this is QS_SIZE.
function SlotPitch( data )

    return SlotArt( data ) + SlotLead( data )

end

-- pixel rect of the *visible* bar. the move header always sits above data.top,
-- visible or not, so data.top is MOVE_HEADER_HEIGHT above the bar itself.
-- the offset is the same for every bar, so it cancels out of bar to bar maths
-- and only matters when comparing against the screen - and it stays a literal
-- 20 at every scale, which is what lets bars of different scales share all the
-- bar to bar maths unchanged.
-- the size runs one SlotEdge past the last slot control. that looks uneven
-- written down - the grid starts at the smaller SlotLead - and it is exactly
-- what makes the rendered bar even, because the icon at the start of the row is
-- already pushed in by the quickslot's own inset and the one at the end is not.
-- at scale 1 this is the original FRAME*4; do not "fix" it to match SlotLead.
function BarRect( data )

    local pitch = SlotPitch( data )
    local edge = SlotEdge( data )

    return data.left,
           data.top + MOVE_HEADER_HEIGHT,
           ( pitch * data.width )  + edge,
           ( pitch * data.height ) + edge

end

-- full window size including the move header. this is what has to stay on
-- screen: a bar whose header is off the top edge can never be grabbed again.
function WindowSize( data )

    local pitch = SlotPitch( data )
    local edge = SlotEdge( data )

    return ( pitch * data.width )  + edge,
           ( pitch * data.height ) + edge + MOVE_HEADER_HEIGHT

end

-- keep a rect inside the screen. the far edge is applied first so a rect bigger
-- than the screen keeps its top left corner on screen instead of hanging off
-- the top (ported from Gibberish3/UTILS/Functions.lua)
function ClampToScreen( left, top, width, height )

    local screen_width, screen_height = Turbine.UI.Display.GetSize()

    if left > screen_width - width then
        left = screen_width - width
    end

    if top > screen_height - height then
        top = screen_height - height
    end

    if left < 0 then
        left = 0
    end

    if top < 0 then
        top = 0
    end

    return left, top

end
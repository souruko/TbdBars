-- fix color from savefile to Turbine.UI.Color
function ColorFix(color)
    if color == nil then
        return nil
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

-- pixel rect of the *visible* bar. the move header always sits above data.top,
-- visible or not, so data.top is MOVE_HEADER_HEIGHT above the bar itself.
-- the offset is the same for every bar, so it cancels out of bar to bar maths
-- and only matters when comparing against the screen.
function BarRect( data )

    return data.left,
           data.top + MOVE_HEADER_HEIGHT,
           ( QS_SIZE * data.width )  + ( FRAME * 4 ),
           ( QS_SIZE * data.height ) + ( FRAME * 4 )

end

-- full window size including the move header. this is what has to stay on
-- screen: a bar whose header is off the top edge can never be grabbed again.
function WindowSize( data )

    return ( QS_SIZE * data.width )  + ( FRAME * 4 ),
           ( QS_SIZE * data.height ) + ( FRAME * 4 ) + MOVE_HEADER_HEIGHT

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
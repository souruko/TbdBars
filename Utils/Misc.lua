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
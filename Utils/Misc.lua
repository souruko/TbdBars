-- fix color from savefile to Turbine.UI.Color
function ColorFix(color)
    if color == nil then
        return nil
    end
	return Turbine.UI.Color(color.R, color.G, color.B)
end

--[[
    the two screen centre guide lines shown in move mode

    each line is a top level Turbine.UI.Window - a Control would be clipped to
    its parent and could not draw over the game world - with one inner Control
    as a darker core, so the line stays readable against any terrain.

    every piece is SetMouseVisible(false): a mouse visible guide would sit on
    top of the bars and eat the drag.

    the gap is drawn per bar, by GapFrame, not here.
]]

Guides = class()

function Guides:Constructor()

    self.active_x = false
    self.active_y = false

    self.vertical   = Turbine.UI.Window()
    self.horizontal = Turbine.UI.Window()

    self.vertical_core   = Turbine.UI.Control()
    self.horizontal_core = Turbine.UI.Control()

    self.vertical_core:SetParent(self.vertical)
    self.horizontal_core:SetParent(self.horizontal)

    for key, piece in ipairs({ self.vertical, self.horizontal, self.vertical_core, self.horizontal_core }) do
        piece:SetMouseVisible(false)
    end

    self.vertical:SetBackColor(GUIDE_COLOR)
    self.horizontal:SetBackColor(GUIDE_COLOR)
    self.vertical_core:SetBackColor(GUIDE_COLOR_CORE)
    self.horizontal_core:SetBackColor(GUIDE_COLOR_CORE)

    self:Refresh()

    self.vertical:SetVisible(false)
    self.horizontal:SetVisible(false)

end


-- re-read the screen size and re-centre both lines. there is no resolution
-- change event in the api, so this is called on every move mode toggle and
-- reload rather than in response to a resize.
function Guides:Refresh()

    local screen_width, screen_height = Turbine.UI.Display.GetSize()

    local core = math.floor( GUIDE_THICKNESS / 2 )
    local inset = math.floor( ( GUIDE_THICKNESS - core ) / 2 )

    self.vertical:SetSize( GUIDE_THICKNESS, screen_height )
    self.vertical:SetPosition( math.floor( screen_width / 2 ) - math.floor( GUIDE_THICKNESS / 2 ), 0 )
    self.vertical_core:SetSize( core, screen_height )
    self.vertical_core:SetPosition( inset, 0 )

    self.horizontal:SetSize( screen_width, GUIDE_THICKNESS )
    self.horizontal:SetPosition( 0, math.floor( screen_height / 2 ) - math.floor( GUIDE_THICKNESS / 2 ) )
    self.horizontal_core:SetSize( screen_width, core )
    self.horizontal_core:SetPosition( 0, inset )

end


function Guides:Show( state )

    self:SetActive( false, false )

    self.vertical:SetVisible(state)
    self.horizontal:SetVisible(state)

end


-- brighten the axis a bar is currently snapped to. only touches the setter on
-- an actual state change, because this runs on every mouse move event.
function Guides:SetActive( x, y )

    if x ~= self.active_x then
        self.active_x = x
        if x then
            self.vertical:SetBackColor(GUIDE_COLOR_ACTIVE)
        else
            self.vertical:SetBackColor(GUIDE_COLOR)
        end
    end

    if y ~= self.active_y then
        self.active_y = y
        if y then
            self.horizontal:SetBackColor(GUIDE_COLOR_ACTIVE)
        else
            self.horizontal:SetBackColor(GUIDE_COLOR)
        end
    end

end


-- top level windows survive a /plugins refresh as orphans, so this is required
function Guides:Close()

    self.vertical_core:SetParent(nil)
    self.horizontal_core:SetParent(nil)

    self.vertical:SetVisible(false)
    self.horizontal:SetVisible(false)

    self.vertical:Close()
    self.horizontal:Close()

end

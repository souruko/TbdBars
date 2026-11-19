
--[[
    the snap gap, drawn around one bar while move mode is on

    four bands, each Data.gap pixels thick, hugging the bar's visible rect on
    all four sides: the ground a neighbouring bar will be held off by when it
    snaps alongside this one. one of these belongs to each QuickslotWindow.

    four separate bands rather than one box behind the bar, for two reasons.
    a box would have to be drawn *under* the bar to not cover it, and the
    z order of two top level windows against each other is not something the
    api lets us state; and the bands leave the bar's own pixels untouched, so
    there is nothing to get wrong. the top and bottom bands run the full outer
    width so the corners are filled by them and the side bands stay short.

    each band is a top level Turbine.UI.Window and has to be: the frame reaches
    outside its bar's window, and a Window clips its children, so a child
    control could not draw there. that also means they are orphaned by a
    /plugins refresh unless Close() runs - hence QuickslotWindow:Closing.

    every band is SetMouseVisible(false). the top one lands in the same strip as
    the move handle, so a mouse visible band would sit on the handle and eat the
    drag it is there to illustrate.
]]

GapFrame = class()

function GapFrame:Constructor()

    self.pieces = {}
    self.shown = false

    for i = 1, 4, 1 do

        local piece = Turbine.UI.Window()

        piece:SetMouseVisible(false)
        piece:SetBackColor(GAP_FRAME_COLOR)

        -- bounced through 0 first, because lotro drops a setter whose value has
        -- not changed and a window starts fully opaque: without the bounce
        -- SetOpacity would be a no-op on anything that happens to already be at
        -- the target. the same trap ForceOpacity exists for in the sibling
        -- plugins (see the parent CLAUDE.md).
        piece:SetOpacity(0)
        piece:SetOpacity(GAP_FRAME_OPACITY)

        piece:SetVisible(false)

        self.pieces[i] = piece

    end

end


-- put the frame around this bar, or take it away. the single entry point, so
-- there is one place that decides whether there is a frame to show: move mode
-- has to be on *and* the gap has to be non zero, and /tbd gap can change the
-- second of those at any time.
--
-- a gap of zero returns before touching a single band's geometry, which is both
-- honest - bars that snap flush have no gap to draw - and the guard that keeps
-- SetSize(0, ...) off a band.
function GapFrame:Apply( data, visible )

    local gap = Utils.GapSize()

    if not visible or gap == 0 then
        self:Show(false)
        return
    end

    local x, y, w, h = Utils.BarRect( data )

    -- top and bottom carry the corners, so they run gap pixels wider at each
    -- end than the bar; the sides fill the bar's own height between them
    self:Place( 1, x - gap, y - gap, w + ( gap * 2 ), gap )
    self:Place( 2, x - gap, y + h,   w + ( gap * 2 ), gap )
    self:Place( 3, x - gap, y,       gap,             h   )
    self:Place( 4, x + w,   y,       gap,             h   )

    self:Show(true)

end


function GapFrame:Place( index, left, top, width, height )

    self.pieces[index]:SetPosition( left, top )
    self.pieces[index]:SetSize( width, height )

end


function GapFrame:Show( state )

    if state == self.shown then
        return
    end

    self.shown = state

    for i, piece in ipairs(self.pieces) do
        piece:SetVisible(state)
    end

end


-- top level windows survive a /plugins refresh as orphans, so this is required
function GapFrame:Close()

    for i, piece in ipairs(self.pieces) do
        piece:SetVisible(false)
        piece:Close()
    end

    self.pieces = {}
    self.shown = false

end


--[[
    
    data:

    - left
    - top
    - width (in qickslot count)
    - height (in qickslot count)
    - background color

]]

QuickslotWindow = class( Turbine.UI.Window )

function QuickslotWindow:Constructor(data, index)
    Turbine.UI.Window.Constructor( self )

    self.data = data
    self.index = index
    self.quickslots = {}

    local move_header_width = 200
    local move_header_height = 20
    local width = ( QS_SIZE * self.data.width) + ( FRAME * 4 )
    local height = ( QS_SIZE * self.data.height) + ( FRAME * 4 )

    self:SetPosition(self.data.left, self.data.top)
    self:SetSize(width, height + move_header_height)
    self:SetMouseVisible(false)

    self.move_header = Turbine.UI.Window()
    self.move_header:SetParent(self)
    self.move_header:SetSize(move_header_width, move_header_height)
    self.move_header:SetPosition( 0 , 0)
    self.move_header:SetBackColor(Turbine.UI.Color.Yellow)
    self.move_header:SetMouseVisible(true)

    self.move_header.MouseDown = function( sender, args )
		if args.Button == Turbine.UI.MouseButton.Left then
			self.dragging = true	
			self.dragStartX = args.X
            self.dragStartY = args.Y
		end
	end
	
	self.move_header.MouseMove = function( sender, args )
		if self.dragging then
			local x,y = self:GetPosition()	
			x = x + ( args.X - self.dragStartX )
            y = y + ( args.Y - self.dragStartY )
            self.data.left = x
            self.data.top = y

            self:SetPosition( x, y )
            self.move_label:SetText("<" .. self.index .. "> left: " .. self:GetLeft() .. " top: " .. self:GetTop())
  		end
	end

	self.move_header.MouseUp = function( sender, args )
		if args.Button == Turbine.UI.MouseButton.Left then
			self.dragging = false

		end
    end

    self.move_label = Turbine.UI.Label()
    self.move_label:SetParent(self.move_header)
    self.move_label:SetSize(move_header_width, move_header_height)
    self.move_label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.move_label:SetForeColor(Turbine.UI.Color.Black)
    self.move_label:SetText("<" .. self.index .. "> left: " .. self:GetLeft() .. " top: " .. self:GetTop())
    self.move_label:SetMouseVisible(false)

    self.background = Turbine.UI.Window()
    self.background:SetParent(self)
    self.background:SetPosition(0, move_header_height)
    self.background:SetBackColor( Utils.ColorFix( self.data.color ) )
    self.background:SetSize(width, height)
    self.background:SetMouseVisible(true)

    self:ResetQuickslots()

    self:SetVisible(true)
    self.background:SetVisible(true)
    self.move_header:SetVisible(false)


end

function QuickslotWindow:QSDataChanged(index, type, data)
    
    self.data.quickslots[index] = {}
    self.data.quickslots[index].Type = type
    self.data.quickslots[index].Data = data

    Save()

end

function QuickslotWindow:Move( state )

    self.move_header:SetVisible(state)
    
end


function QuickslotWindow:ResetQuickslots()

    self:ClearQuickslots()
    self:CreateQuickslots()

end


function QuickslotWindow:ClearQuickslots()
    
    for key, quickslot in ipairs(self.quickslots) do

        quickslot:SetVisible(false)
        quickslot:SetMouseVisible(false)
        quickslot:SetParent(nil)

    end

    self.quickslots = {}

end


function QuickslotWindow:CreateQuickslots()

    for i=1, self.data.height, 1 do

        for j=1, self.data.width, 1 do

            local left = FRAME + ( (j - 1) * QS_SIZE )
            local top = FRAME + ( (i - 1) * QS_SIZE )
            local index = #self.quickslots + 1

            self.quickslots[index] = Turbine.UI.Lotro.Quickslot()
            self.quickslots[index]:SetParent(self.background)
            self.quickslots[index]:SetPosition(left, top)
            self.quickslots[index].index = index
            self.quickslots[index].window = self
            
            if self.data.quickslots[index] ~= nil then
                self.quickslots[index]:SetShortcut( Turbine.UI.Lotro.Shortcut( self.data.quickslots[index].Type, self.data.quickslots[index].Data ) )
            end

            self.quickslots[index].ShortcutChanged = function (sender, args)

                local shortcut = sender:GetShortcut()
                sender.window:QSDataChanged(sender.index, shortcut:GetType(), shortcut:GetData())

            end

        end

    end
    
end

function QuickslotWindow:Closing()

    self:SetVisible(false)
    self.background:SetVisible(false)
    self.move_header:SetVisible(false)

    self.background:Close()
    self.move_header:Close()
    
end
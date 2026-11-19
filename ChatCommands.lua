
function PrintHelp()
    local function h(cmd, desc)
        Turbine.Shell.WriteLine(string.format("  %-28s-- %s", cmd, desc))
    end
    Turbine.Shell.WriteLine("TbdBars commands (/tbd or /tbdbars):")
    h("add <w> <h>",               "Add a new bar (1-20 slots wide/tall)")
    h("remove <index>",            "Remove a bar")
    h("resize <index> <w> <h>",    "Resize a bar")
    h("scale <factor>",            "Scale the selected bars (0.5 to 5, two decimals)")
    h("color <index> <r> <g> <b>", "Set bar background color (0-255 each)")
    h("opacity <index> <0-100>",   "Set bar opacity")
    h("move",                      "Toggle move mode")
    h("select all|none",           "Select or deselect every bar")
    h("select <index> ...",        "Toggle selection of one or more bars")
    h("gap <pixels>",              "Spacing bars keep when they snap beside each other")
    h("clear all|<bar>|<bar> <slot>", "Empty every slot, a whole bar, or one slot")
    h("lock",                      "Lock bars so nothing can be dropped on them")
    h("list",                      "List all bars with index, size, position and fill")
    h("layout save <name>",        "Save current bar positions as a layout")
    h("layout load <name>",        "Load a saved layout")
    h("layout delete <name>",      "Delete a saved layout")
    h("layout overview",           "List all saved layouts")
    Turbine.Shell.WriteLine("  In move mode, left-click a handle to select just that bar, or")
    Turbine.Shell.WriteLine("  ctrl+left-click to add or remove it from the selection. Dragging")
    Turbine.Shell.WriteLine("  any selected handle moves them all, and /tbd scale applies to")
    Turbine.Shell.WriteLine("  whatever is selected.")
end

function ListWindows()
    local cluster = Data[Data.activ]
    local count = #cluster
    local lock = ""
    -- the lock persists now, so it is easy to forget it is on - say so here
    if Activ_Cluster ~= nil and Activ_Cluster.locked then
        lock = " [locked]"
    end
    Turbine.Shell.WriteLine("Windows (" .. count .. ")" .. lock .. ":")
    for idx, window_data in ipairs(cluster) do
        local mark = ""
        if Activ_Cluster ~= nil and Activ_Cluster:IsSelected(idx) then
            mark = " [selected]"
        end
        -- the fill count makes the slot numbers /tbd clear takes discoverable
        local filled = 0
        for i = 1, window_data.width * window_data.height, 1 do
            if window_data.quickslots ~= nil and window_data.quickslots[i] ~= nil then
                filled = filled + 1
            end
        end
        -- only shown when it is not 1, so an unscaled setup reads as it always did
        local scale = Utils.ScaleOf( window_data )
        local scale_text = ""
        if scale ~= 1 then
            scale_text = " x" .. scale
        end
        Turbine.Shell.WriteLine("  #" .. idx .. ": " .. window_data.width .. "x" .. window_data.height .. scale_text ..
            " at (" .. window_data.left .. ", " .. window_data.top .. "), " ..
            filled .. "/" .. (window_data.width * window_data.height) .. " slots filled" .. mark)
    end
    if count == 0 then
        Turbine.Shell.WriteLine("  No windows on this trait line.")
    end
end

command = Turbine.ShellCommand()

function command:Execute( _, str )
    if str == nil or string.len( str ) == 0 then
        PrintHelp()
        return
    end

    local list = {}
    local i = 1

    -- %S+ and not %w+. %w is alphanumerics only, so the old pattern split
    -- "3.05" into "3" and "05" and /tbd scale 3.05 would silently have scaled
    -- by 3. every command either runs its arguments through tonumber or
    -- compares them against fixed words, and layout names were only ever
    -- restricted to word characters by this very pattern, so widening it takes
    -- nothing away - it also makes /tbd layout save my-layout work.
    for word in str:gmatch( "%S+" ) do
        list[ i ] = word
        i = i + 1
    end

    local cmd = string.lower( list[ 1 ] )

    if cmd == "help" then

        PrintHelp()

    elseif cmd == "list" then

        ListWindows()

    elseif cmd == "remove" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine( "Usage: /tbd remove <index>")
            return
        end
        local idx = tonumber(list[ 2 ])
        if idx == nil then
            Turbine.Shell.WriteLine("Invalid index.")
            return
        end
        if Data[Data.activ][idx] == nil then
            Turbine.Shell.WriteLine("No window at index " .. idx .. ".")
            return
        end

        -- RemoveWindow swaps the last bar into the freed slot, so an index
        -- held in the selection would now point at a different bar
        Activ_Cluster:ClearSelection()

        RemoveWindow(idx)
        Activ_Cluster:Reload()
        Turbine.Shell.WriteLine("Removed window #" .. idx .. ".")

    elseif cmd == "add" then

        if list[ 2 ] == nil or list[ 3 ] == nil then
            Turbine.Shell.WriteLine( "Usage: /tbd add <width> <height>")
            return
        end
        local width = tonumber(list[ 2 ])
        local height = tonumber(list[ 3 ])

        if width == nil or height == nil
            or width < 1 or height < 1 or width > 20 or height > 20
            or math.floor(width) ~= width or math.floor(height) ~= height then
            Turbine.Shell.WriteLine("Width and height must be whole numbers between 1 and 20.")
            return
        end

        local new_index = #Data[Data.activ] + 1
        AddNewWindow(width, height)
        Activ_Cluster:Reload()
        Turbine.Shell.WriteLine("Added window #" .. new_index .. " (" .. width .. "x" .. height .. ").")

    elseif cmd == "resize" then

        if list[2] == nil or list[3] == nil or list[4] == nil then
            Turbine.Shell.WriteLine("Usage: /tbd resize <index> <width> <height>")
            return
        end
        local idx = tonumber(list[2])
        local width = tonumber(list[3])
        local height = tonumber(list[4])

        if idx == nil or width == nil or height == nil
            or width < 1 or height < 1 or width > 20 or height > 20
            or math.floor(width) ~= width or math.floor(height) ~= height then
            Turbine.Shell.WriteLine("Invalid parameters. Width and height must be whole numbers between 1 and 20.")
            return
        end

        ResizeWindow(idx, width, height)
        Activ_Cluster:Reload()
        Turbine.Shell.WriteLine("Resized window #" .. idx .. " to " .. width .. "x" .. height .. ".")

    elseif cmd == "scale" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine("Usage: /tbd scale <factor>  (" .. SCALE_MIN .. " to " .. SCALE_MAX ..
                ", two decimals, applies to the selected bars)")
            for idx, window_data in ipairs(Data[Data.activ]) do
                Turbine.Shell.WriteLine("  #" .. idx .. ": x" .. Utils.ScaleOf(window_data))
            end
            return
        end

        local scale = tonumber(list[ 2 ])

        if scale == nil or scale < SCALE_MIN or scale > SCALE_MAX then
            Turbine.Shell.WriteLine("Scale must be a number between " .. SCALE_MIN .. " and " .. SCALE_MAX .. ".")
            return
        end

        -- two decimals is the advertised precision, and finer than that is
        -- under a pixel at this slot size anyway
        scale = math.floor( ( scale * 100 ) + 0.5 ) / 100

        -- indices, not window objects: Reload below destroys every window and
        -- builds new ones, so anything held across it is a stale orphan
        local targets = {}

        for i, window in ipairs( Activ_Cluster:SelectedWindows() ) do
            targets[#targets + 1] = window.index
        end

        if #targets == 0 then
            Turbine.Shell.WriteLine("No bars selected. Run /tbd select <index>, or /tbd move and click a handle.")
            return
        end

        for i, index in ipairs(targets) do
            ScaleWindow( index, scale )
        end

        Activ_Cluster:Reload()

        -- a scale change never goes through MoveTo, which is the only clamp
        -- site, so a bar scaled up at the edge of the screen would hang off it.
        -- a zero move re-clamps and leaves the top left exactly where it was
        -- unless the far edge has left the screen.
        for i, index in ipairs(targets) do
            if Activ_Cluster.windows[index] ~= nil then
                Activ_Cluster.windows[index]:MoveBy( 0, 0 )
            end
        end

        Turbine.Shell.WriteLine("Scaled " .. #targets .. " bar(s) to x" .. scale .. ".")

    elseif cmd == "color" then

        if list[2] == nil or list[3] == nil or list[4] == nil or list[5] == nil then
            Turbine.Shell.WriteLine("Usage: /tbd color <index> <r> <g> <b>  (0-255 each)")
            return
        end
        local idx = tonumber(list[2])
        local r = tonumber(list[3])
        local g = tonumber(list[4])
        local b = tonumber(list[5])

        if idx == nil or r == nil or g == nil or b == nil
            or r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
            Turbine.Shell.WriteLine("Invalid parameters. R, G, B must be between 0 and 255.")
            return
        end

        SetWindowColor(idx, r, g, b)
        Activ_Cluster:Reload()
        Turbine.Shell.WriteLine("Set color of window #" .. idx .. " to (" .. r .. ", " .. g .. ", " .. b .. ").")

    elseif cmd == "opacity" then

        if list[2] == nil or list[3] == nil then
            Turbine.Shell.WriteLine("Usage: /tbd opacity <index> <0-100>")
            return
        end
        local idx = tonumber(list[2])
        local value = tonumber(list[3])

        if idx == nil or value == nil or value < 0 or value > 100 then
            Turbine.Shell.WriteLine("Invalid parameters. Opacity must be between 0 and 100.")
            return
        end

        SetWindowOpacity(idx, value)
        Activ_Cluster:Reload()
        Turbine.Shell.WriteLine("Set opacity of window #" .. idx .. " to " .. value .. "%.")

    elseif cmd == "move" then

        Activ_Cluster:Move()
        Save()

    elseif cmd == "select" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine( "Usage: /tbd select <all|none|index ...>")
            return
        end

        local sub = string.lower( list[ 2 ] )

        if sub == "none" then

            Activ_Cluster:ClearSelection()
            Turbine.Shell.WriteLine("Selection cleared.")
            return
        end

        if sub == "all" then

            Activ_Cluster:SelectAll()

        else

            for i = 2, #list, 1 do
                local idx = tonumber(list[ i ])
                if idx == nil or Data[Data.activ][idx] == nil then
                    Turbine.Shell.WriteLine("No window at index " .. list[ i ] .. ".")
                else
                    Activ_Cluster:ToggleSelected(idx)
                end
            end

        end

        Turbine.Shell.WriteLine("Selected bars: " .. Activ_Cluster:SelectionCount() .. ".")

        if not Activ_Cluster.moving then
            Turbine.Shell.WriteLine("Move mode is off - run /tbd move to see the handles.")
        end

    elseif cmd == "gap" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine("Snap gap is " .. Data.gap .. "px. Usage: /tbd gap <pixels>")
            return
        end

        local gap = tonumber(list[ 2 ])

        if gap == nil or gap < 0 or gap > 200 or math.floor(gap) ~= gap then
            Turbine.Shell.WriteLine("Gap must be a whole number of pixels between 0 and 200.")
            return
        end

        SetSnapGap(gap)

        Activ_Cluster:GapChanged()

        if gap == 0 then
            Turbine.Shell.WriteLine("Snap gap cleared - bars now snap flush against each other.")
        else
            Turbine.Shell.WriteLine("Snap gap set to " .. gap .. "px.")

            if not Activ_Cluster.moving then
                Turbine.Shell.WriteLine("Run /tbd move to see it drawn around the bars.")
            end
        end

    elseif cmd == "clear" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine("Usage: /tbd clear all | <bar> | <bar> <slot>")
            return
        end

        local window_index = nil
        local slot_index = nil

        if string.lower( list[ 2 ] ) ~= "all" then

            window_index = tonumber(list[ 2 ])

            if window_index == nil or Data[Data.activ][window_index] == nil then
                Turbine.Shell.WriteLine("No bar at index " .. list[ 2 ] .. ". Run /tbd list.")
                return
            end

            if list[ 3 ] ~= nil then

                local bar = Data[Data.activ][window_index]
                local slots = bar.width * bar.height

                slot_index = tonumber(list[ 3 ])

                if slot_index == nil or slot_index < 1 or slot_index > slots
                    or math.floor(slot_index) ~= slot_index then
                    Turbine.Shell.WriteLine("Bar #" .. window_index .. " has slots 1 to " .. slots ..
                        ", counted left to right then top to bottom.")
                    return
                end

            end

        end

        local cleared = Activ_Cluster:ClearSlots( window_index, slot_index )

        -- nil means the lock refused and has already said so
        if cleared == nil then
            return
        end

        if cleared == 0 then
            Turbine.Shell.WriteLine("Nothing to clear - those slots were already empty.")
        elseif slot_index ~= nil then
            Turbine.Shell.WriteLine("Cleared slot " .. slot_index .. " of bar #" .. window_index .. ".")
        elseif window_index ~= nil then
            Turbine.Shell.WriteLine("Cleared " .. cleared .. " slot(s) on bar #" .. window_index .. ".")
        else
            Turbine.Shell.WriteLine("Cleared " .. cleared .. " slot(s) across every bar on this trait line.")
        end

    elseif cmd == "lock" then

        Activ_Cluster:Lock()

    elseif cmd == "layout" then

        if list[ 2 ] == nil then
            Turbine.Shell.WriteLine( "Usage: /tbd layout <save|load|delete|overview> [name]")
            return
        end

        if list[2] == "load" then

            if list[ 3 ] == nil then
                Turbine.Shell.WriteLine( "Missing Layout Name.")
                return
            end

            LoadLayout(list[3])

        elseif list[2] == "save" then

            if list[ 3 ] == nil then
                Turbine.Shell.WriteLine( "Missing Layout Name.")
                return
            end

            SaveLayout(list[3])

        elseif list[2] == "delete" then

            if list[ 3 ] == nil then
                Turbine.Shell.WriteLine( "Missing Layout Name.")
                return
            end

            DeleteLayout(list[3])

        elseif list[2] == "overview" then

            PrintLayout()

        else
            Turbine.Shell.WriteLine("Unknown layout subcommand. Use: save, load, delete, overview")
        end

    else
        Turbine.Shell.WriteLine("Unknown command '" .. cmd .. "'. Type /tbd help for a list of commands.")
    end

end


Turbine.Shell.AddCommand( "tbd", command )
Turbine.Shell.AddCommand( "tbdbars", command )


function PrintHelp()
    local function h(cmd, desc)
        Turbine.Shell.WriteLine(string.format("  %-28s-- %s", cmd, desc))
    end
    Turbine.Shell.WriteLine("TbdBars commands (/tbd or /tbdbars):")
    h("add <w> <h>",               "Add a new bar (1-20 slots wide/tall)")
    h("remove <index>",            "Remove a bar")
    h("resize <index> <w> <h>",    "Resize a bar")
    h("color <index> <r> <g> <b>", "Set bar background color (0-255 each)")
    h("opacity <index> <0-100>",   "Set bar opacity")
    h("move",                      "Toggle move mode")
    h("lock",                      "Toggle quickslot lock")
    h("list",                      "List all bars with index, size, and position")
    h("layout save <name>",        "Save current bar positions as a layout")
    h("layout load <name>",        "Load a saved layout")
    h("layout delete <name>",      "Delete a saved layout")
    h("layout overview",           "List all saved layouts")
end

function ListWindows()
    local cluster = Data[Data.activ]
    local count = #cluster
    Turbine.Shell.WriteLine("Windows (" .. count .. "):")
    for idx, window_data in ipairs(cluster) do
        Turbine.Shell.WriteLine("  #" .. idx .. ": " .. window_data.width .. "x" .. window_data.height ..
            " at (" .. window_data.left .. ", " .. window_data.top .. ")")
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

    for word in str:gmatch( "%w+" ) do
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


command = Turbine.ShellCommand()

function command:Execute( _, str )
    if str == nil or string.len( str ) == 0 then
        Turbine.Shell.WriteLine( "Missing Argument.")
        return
    end

    local list  = { }
    local index = 1

    for word in str:gmatch( "%w+" ) do
        list[ index ] = word
        index = index + 1
    end

    local cmd = string.lower( list[ 1 ] )

    if cmd == "remove" then

        if list[ 2 ] == nil or string.len( list[ 2 ] ) == 0 then
            Turbine.Shell.WriteLine( "Missing Index.")
            return
        end
        local index = tonumber(list[ 2 ])

        RemoveWindow(index)
        Activ_Cluster:Reload()

    elseif cmd == "add" then

        if list[ 2 ] == nil or string.len( list[ 2 ] ) == 0 or list[ 3 ] == nil or string.len( list[ 3 ] ) == 0 then
            Turbine.Shell.WriteLine( "Missing Parameter (width/height).")
            return
        end
        local width = tonumber(list[ 2 ])
        local height = tonumber(list[ 3 ])

        AddNewWindow(width, height, Turbine.UI.Color.Black)
        Activ_Cluster:Reload()

    elseif cmd == "move" then

        Activ_Cluster:Move()
        Save()

    elseif cmd == "layout" then

        if list[ 2 ] == nil or string.len( list[ 2 ] ) == 0 then
            Turbine.Shell.WriteLine( "Missing Parameter (load/save/overview).")
            return
        end

        if list[2] == "load" then

            if list[ 3 ] == nil or string.len( list[ 3 ] ) == 0 then
                Turbine.Shell.WriteLine( "Missing Layout Name.")
                return
            end

            LoadLayout(list[3])

            
        elseif list[2] == "save" then

            if list[ 3 ] == nil or string.len( list[ 3 ] ) == 0 then
                Turbine.Shell.WriteLine( "Missing Layout Name.")
                return
            end

            SaveLayout(list[3])

        elseif list[2] == "overview" then

            PrintLayout()

        end

    end

end


Turbine.Shell.AddCommand( "tbd", command )
Turbine.Shell.AddCommand( "tbdbars", command )

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

    if cmd == "options" then

    elseif cmd == "move" then
        Activ_Cluster:Move()
    end

end


Turbine.Shell.AddCommand( "tbd", command )
Turbine.Shell.AddCommand( "tbdbars", command )
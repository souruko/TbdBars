
function AddNewWindow(width, height)

    local cluster = Data[Data.activ]
    local index = #cluster + 1

    cluster[index] = {}
    cluster[index].left = 200 + (index - 1) * 50
    cluster[index].top = 200 + (index - 1) * 50
    cluster[index].width = width
    cluster[index].height = height
    cluster[index].color = {R = 0, G = 0, B = 0}
    cluster[index].opacity = 1
    cluster[index].quickslots = {}

    Save()

end

function RemoveWindow( index )

    local cluster = Data[Data.activ]

    if cluster[index] == nil then
        return
    end

    cluster[index] = cluster[#cluster]
    cluster[#cluster] = nil

    Save()

end

function SetWindowColor(index, r, g, b)

    local cluster = Data[Data.activ]

    if cluster[index] == nil then
        Turbine.Shell.WriteLine("No window at index " .. index .. ".")
        return
    end

    cluster[index].color = {R = r / 255, G = g / 255, B = b / 255}

    Save()

end

function SetWindowOpacity(index, value)

    local cluster = Data[Data.activ]

    if cluster[index] == nil then
        Turbine.Shell.WriteLine("No window at index " .. index .. ".")
        return
    end

    cluster[index].opacity = value / 100

    Save()

end

function ResizeWindow(index, width, height)

    local cluster = Data[Data.activ]

    if cluster[index] == nil then
        Turbine.Shell.WriteLine("No window at index " .. index .. ".")
        return
    end

    cluster[index].width = width
    cluster[index].height = height

    Save()

end


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
    cluster[index].scale = 1
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

-- spacing kept between bars when one snaps beside another. account wide would
-- be nicer but Data is the character save, and bar geometry is per character
-- anyway, so this lives alongside it.
function SetSnapGap(value)

    Data.gap = value

    Save()

end

-- per bar rather than per trait line, so one bar can be big and another small.
-- nothing defaults it on load: Utils.ScaleOf treats a missing value as 1, which
-- is what keeps savefiles and layout snapshots written before this existed
-- working without a migration.
function ScaleWindow(index, scale)

    local cluster = Data[Data.activ]

    if cluster[index] == nil then
        Turbine.Shell.WriteLine("No window at index " .. index .. ".")
        return
    end

    cluster[index].scale = scale

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

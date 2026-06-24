
function AddNewWindow(width, height, color)

    local cluster = Data[Data.activ]
    local index = #cluster + 1

    cluster[index] = {}
    cluster[index].left = 200
    cluster[index].top = 200
    cluster[index].width = width
    cluster[index].height = height
    cluster[index].color = color
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
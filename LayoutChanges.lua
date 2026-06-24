
function LayoutChanged( new_traitline )

    Data.activ = new_traitline
    Activ_Cluster:Close()
    Activ_Cluster = nil
    Activ_Cluster = Elements.Cluster(Data[ Data.activ ])

    Save()
    
end


function Turbine.Chat.Received(sender, args)

    if args.ChatType == Turbine.ChatType.Advancement then

        if string.find(args.Message, ClassSpecializationString) then

            for traitline, traitline_name in ipairs(ClassStrings[LP_CLASS]) do

                if string.find(args.Message, traitline_name) then
                    LayoutChanged( traitline )
                end

            end

        end

    end

end


function LoadLayout(name)

    if Layout[name] ~= nil then

        Data[Data.activ] = {}

        for index, window_data in ipairs(Layout[name]) do

            Data[Data.activ][index] = {}

            Data[Data.activ][index].top = window_data.top
            Data[Data.activ][index].left = window_data.left
            Data[Data.activ][index].width = window_data.width
            Data[Data.activ][index].height = window_data.height
            Data[Data.activ][index].quickslots = {}
            Data[Data.activ][index].color = window_data.color
            Data[Data.activ][index].opacity = window_data.opacity

        end

        LayoutChanged(Data.activ)

        Save()

        Turbine.Shell.WriteLine("Loaded Layout <" .. name .. "> as Active.")

    
    else
        Turbine.Shell.WriteLine("No layout with the name < " .. name .. " > saved.")
    end

end

function SaveLayout(name)

    Layout[name] = {}

    for index, window_data in ipairs(Data[Data.activ]) do

        Layout[name][index] = {}
        Layout[name][index].top =  window_data.top
        Layout[name][index].left =  window_data.left
        Layout[name][index].width =  window_data.width
        Layout[name][index].height =  window_data.height
        Layout[name][index].color =  window_data.color
        Layout[name][index].opacity =  window_data.opacity
    
    end

    Turbine.Shell.WriteLine("Activ Layout Saved as: ".. name)

    SaveLayoutData()

end

function PrintLayout()

    Turbine.Shell.WriteLine("Saved Layout Overview:")

    local counter = 0;
    for key, value in pairs(Layout) do
        counter = counter + 1;
        Turbine.Shell.WriteLine(counter.. ": " ..key)
    end

    if counter == 0 then
        Turbine.Shell.WriteLine("- No Layouts Saved. -")
    end

end

function DeleteLayout(name)

    if Layout[name] ~= nil then
        Layout[name] = nil
        SaveLayoutData()
        Turbine.Shell.WriteLine("Deleted layout: " .. name .. ".")
    else
        Turbine.Shell.WriteLine("No layout with the name <" .. name .. "> saved.")
    end

end
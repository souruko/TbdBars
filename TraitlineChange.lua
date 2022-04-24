
function TraitLineChanged( new_traitline )

    Data.activ = new_traitline
    Activ_Cluster:Close()
    Activ_Cluster = nil
    Activ_Cluster = Elements.Cluster(Data[ Data.activ ])
    
end


function Turbine.Chat.Received(sender, args)

    if args.ChatType == Turbine.ChatType.Advancement then

        if string.find(args.Message, ClassSpecializationString) then

            for traitline, traitline_name in ipairs(ClassStrings[LP_CLASS]) do

                if string.find(args.Message, traitline_name) then
                    TraitLineChanged( traitline )
                end

            end

        end

    end

end
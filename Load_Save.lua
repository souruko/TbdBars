
function Save()

    if Locale == LANGUAGE.English then
        Turbine.PluginData.Save(Turbine.DataScope.Character, "tbdbars", Data)
    else
        local converted = ConvertToEuro(Data)
        Turbine.PluginData.Save(Turbine.DataScope.Character, "tbdbars", converted)
    end
    
end

function SaveLayoutData()

    if Locale == LANGUAGE.English then
        Turbine.PluginData.Save(Turbine.DataScope.Account, "tbdbars_layout", Layout)
    else
        local converted = ConvertToEuro(Layout)
        Turbine.PluginData.Save(Turbine.DataScope.Account, "tbdbars_layout", converted)
    end
    
end


-- fix for german/french client
function ConvertToEuro(dataRaw)
	local newData = {};
	for i, myData in pairs(dataRaw) do
		local tempIndex = nil;
		local tempData = nil;
		if (type(i) == "number") then
			tempIndex = tostring(i);
		else
			tempIndex = i;
		end
		if (type(myData) == "table") then
			tempData = ConvertToEuro(myData);
		elseif (type(myData) == "number") then
			tempData = tostring(myData);
		else
			tempData = myData;
		end
		newData[tempIndex] = tempData;
	end
	return newData;
end

function ConvertFromEuro(dataRaw)
	local newData = {}
	for i, myData in pairs(dataRaw) do
		local tempIndex = tonumber(i);
		if (tempIndex == nil) then
			tempIndex = i;
		end
		local tempData = nil;

		if (type(myData) == "table") then
			tempData = ConvertFromEuro(myData);
		else
			tempData = tonumber(myData);
			if (tempData == nil) then
				tempData = myData;
			end
		end
		newData[tempIndex] = tempData;
	end
	return newData;
	
end


if Turbine.PluginData.Load(Turbine.DataScope.Character, "tbdbars") ~= nil then

    Data = Turbine.PluginData.Load(Turbine.DataScope.Character, "tbdbars")
    if Locale ~= LANGUAGE.English then
        Data = ConvertFromEuro(Data)
    end

else

    Data = {}

    Data[TRAIT_LINE.Red] = {}
    Data[TRAIT_LINE.Yellow] = {}
    Data[TRAIT_LINE.Blue] = {}

    Data.activ = TRAIT_LINE.Red
    Data.version = 1

end

if Turbine.PluginData.Load(Turbine.DataScope.Account, "tbdbars_layout") ~= nil then

    Layout = Turbine.PluginData.Load(Turbine.DataScope.Account, "tbdbars_layout")
    if Locale ~= LANGUAGE.English then
        Layout = ConvertFromEuro(Layout)
    end

else

    Layout = {}

end



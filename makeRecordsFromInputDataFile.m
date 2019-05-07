function [AnalysedData, skipCount] = ...
    makeRecordsFromInputDataFile(indata, areaData, siteData, dateData, rcaData, subrcaData)

   sz = numel(areaData);
   startIndx = 2;
   AnalysedData = indata;
   
   newlyAdded = 1;
   skipCount = 0;
   for i = startIndx:sz
       i
       areaDatavalue = areaData(i);
       if checkIf_NaN_or_Empty(areaDatavalue)
           skipCount = skipCount + 1;
           continue;
       end
       siteDatavalue = siteData(i);
       if checkIf_NaN_or_Empty(siteDatavalue)
           skipCount = skipCount + 1;
           continue;
       end
       rcaDatavalue = rcaData(i);
       if checkIf_NaN_or_Empty(rcaDatavalue)
           skipCount = skipCount + 1;
           continue;
       end
       
       subrcaDataVal = subrcaData(i);
       if checkIf_NaN_or_Empty(subrcaDataVal)
           subrcaDatavalue = sprintf('%s-<NoInfo>',rcaDatavalue{1});
       else
           subrcaDatavalue = sprintf('%s-<%s>',rcaDatavalue{1},subrcaDataVal{1});
       end
       
       dateDatavalue = dateData(i);
       if checkIf_NaN_or_Empty(dateDatavalue)
           skipCount = skipCount + 1;
           continue;
       end
       date_time_info = parsetime_date(dateDatavalue);
       siteDatavalue = sprintf('%s-[(%s)]',areaData{i},siteData{i});
       
       CityPresentIndx = findIndxbyField(AnalysedData(:),'name', areaDatavalue);
       if CityPresentIndx == false   % New city found and we have to add it now in DB
           cityID = numel(AnalysedData);
           CityPresentIndx = cityID +1;
           
           AnalysedData(CityPresentIndx).name = char(areaDatavalue);
           AnalysedData(CityPresentIndx).Site(newlyAdded).name = siteDatavalue;
           AnalysedData(CityPresentIndx).Site(newlyAdded).RCA(newlyAdded).name = char(subrcaDatavalue);
           AnalysedData(CityPresentIndx).Site(newlyAdded).RCA(newlyAdded).instance = (date_time_info);
       else      
           SitePresentIndx = findIndxbyField(AnalysedData(CityPresentIndx).Site(:),'name', siteDatavalue);
           if SitePresentIndx == false
               siteID = numel(AnalysedData(CityPresentIndx).Site);
               SitePresentIndx = siteID + 1;
               AnalysedData(CityPresentIndx).Site(SitePresentIndx).name = siteDatavalue;
               AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(newlyAdded).name = char(subrcaDatavalue);
               AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(newlyAdded).instance = (date_time_info);
           else
               RCAPresentIndx = ...
                   findIndxbyField(AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(:),'name', subrcaDatavalue);
               if RCAPresentIndx ~= false
                   AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).instance = ...
                       [AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).instance, date_time_info];
                   instances = AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).instance;
                   sortedInstance = sortInstances(instances);
                   AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).instance = sortedInstance;
               else
                   rcaID = numel(AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA);
                   RCAPresentIndx = rcaID + 1;
                   AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).name = char(subrcaDatavalue);
                   AnalysedData(CityPresentIndx).Site(SitePresentIndx).RCA(RCAPresentIndx).instance = (date_time_info);
               end
           end
       end
   end
end
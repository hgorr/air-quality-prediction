%% Retrieve Air Quality Data

%%
% Ozone (44201)	SO2 (42401)	CO (42101)	NO2 (42602)
criteria_gas = {'44201','42401','42101','42602'};
%meas = {'RH_DP'};  % 'WIND','TEMP','PRESS','RH_DP'};
% yr = string(1980:2016);
yr = string(2016);

for jj = 1:length(criteria_gas)
%for jj = 1:length(meas)
    for ii = 1:length(yr)
        % save the files from the web
        url = ['http://aqsdr1.epa.gov/aqsweb/aqstmp/airdata/hourly_',... % daily_',...
            criteria_gas{jj},'_',yr{ii},'.zip'];
        fname = ['hourly_',criteria_gas{jj},'_',yr{ii},'.zip'];
        % meteorological data:
%         url = ['http://aqsdr1.epa.gov/aqsweb/aqstmp/airdata/hourly_',...
%             meas{jj},'_',yr{ii},'.zip'];
%         fname = ['hourly_',meas{jj},'_',yr{ii},'.zip'];

        websave(fname,url);
        
        try            
            % unzip the file in the present directory
            fnames = unzip(fname);
            
            % if length(fnames) > 1  % loop if there are many files
            % only one in this case, so build it out later
            newname = fnames{1};
            
            % copy the file(s) to HDFS
            cmd = ['hdfs dfs -copyFromLocal ',newname,' /datasets/AirQuality/hourlyData'];
            %cmd = ['hdfs dfs -copyFromLocal ',newname,' /datasets/AirQuality/meteorologicalData'];
            system(cmd);
            
            % remove the local copies
            cmd2 = ['rm ',fname];
            system(cmd2);
            
            cmd3 = ['rm ',newname];
            system(cmd3);
            disp(['Copied ',newname])
            
        catch 
            warning(['Something went wrong with file: ',fname])
            cmd2 = ['rm ',fname];
            system(cmd2);
        end
    end
    
end
%%


function [currentData,forecast] = ReadDataFromWeb(city,apikey,usePython) 

% Check inputs
if nargin < 3
    usePython = false;
end
if nargin < 2
    t = readtable("accessKey.txt");
    apikey = t.Key;
end
if nargin < 1
    city = "Boston";
end

% Get current weather
if usePython    
    jsonData = py.weather.get_current_weather(city,"us",apikey);
    weatherData = py.weather.parse_json(jsonData);
    currentData = prepData(weatherData);    
else
%     try
        response = getCurrentWeather(city,apikey);
        data = parseJSON(response);
        % Convert data types
        currentData = prepData(data);
%     catch
%         data = readCurrentData(city);
%     end
end

% get forecast data
if usePython
    forecastData = py.weather.get_forecast(city,'us',apikey);
    weatherData = py.weather.parse_forecast(forecastData);
    s = struct(weatherData);
    forecast = prepArrays(s);
else
%     try
        response = getForecastData(city,apikey);
        forecast = parseJSONforecast(response);
%     catch
%         forecast = readForecastData(city);
%     end
end
forecast.DateLocal = datetime(forecast.DateLocal);
forecast = table2timetable(forecast);
% Add DP
forecast.DP = forecast.T-(9/25)*(100-forecast.RH);

% Select data for model prediction
forecast = forecast(:,["T","P",...
    "DP","RH","WindDir","WindSpd"]);


end

%% Helper funs
function response = getCurrentWeather(city,apikey)
url = "https://api.openweathermap.org/data/2.5/weather?q="+city+...
    ",us&units=imperial&appid="+apikey;        
response = webread(url);

end

function response = getForecastData(city,apikey)
url = "https://api.openweathermap.org/data/2.5/forecast?q="+city+...
    ",us&units=imperial&appid="+apikey; 
response = webread(url);

end

function weather_info = parseJSON(response)
T = response.main.temp;
RH = response.main.humidity;
P = response.main.pressure;
WindDir = response.wind.deg;
WindSpd = response.wind.speed;
DateLocal = datetime('now');
lat = response.coord.lat;
lon = response.coord.lon;
city = string(response.name);
% Create new table
weather_info = table(DateLocal,T,P,...
    WindDir,WindSpd,RH,city,lat,lon);
end

function weather_info = parseJSONforecast(response)
% data = response.forecast.simpleforecast.forecastday;
list = response.list;
% create arrays
weather_info = table('Size',[40,6],'VariableNames',["DateLocal",...
    "T","RH","P","WindDir","WindSpd"],...
    'VariableTypes',["string",repmat("double",1,5)]);

for ii = 1:40
    % extract data
    if isstruct(list)
        x1 = list(ii);
    else
        x1 = list{ii};
    end
    weather_info.DateLocal(ii) = x1.dt_txt;
    weather_info.WindDir(ii) = x1.wind.deg;
    weather_info.WindSpd(ii) = x1.wind.speed;
    weather_info.RH(ii) = x1.main.humidity;
    weather_info.T(ii) = x1.main.temp;
    weather_info.P(ii) = x1.main.pressure;
end

end

function forecast = prepArrays(s)
forecast = table(string(cell(s.DateLocal))',double(s.T)',...
    double(s.WindDir)',double(s.WindSpd)',double(s.RH)',double(s.P)');
forecast.Properties.VariableNames = fieldnames(s);
end

% function data = readCurrentData(city)
% data = readtable("backupdata.csv","TextType","string");
% data.StateName = categorical(data.StateName);
% [data.yy,data.MM,data.dd] = ymd(data.DateLocal);
% data = data(data.City == city,2:end);
% end
% 
% function data = readForecastData(city)
% data = readtable("backupforecast.csv","TextType","string");
% data = data(data.City == city,2:end);
% end
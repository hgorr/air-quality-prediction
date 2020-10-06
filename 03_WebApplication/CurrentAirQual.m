function [airQual,T,Tforecast,dates] = CurrentAirQual(loc)

    if nargin < 1
        loc = "Boston";
    end

    apikey = readtable("accessKey.txt","TextType","string"); 
    % Read current weather
    jsonData = py.weather.get_current_weather(loc,"US",apikey.Key(1));
    weatherData = py.weather.parse_current_json(jsonData);
    data = struct(weatherData);
    T = data.temp;
    
    % Convert data types
    airQual = predictAirQual(weatherData);
    
    if nargout > 2
    % 10 day forecast for plot
    jsonData = py.weather.get_forecast(loc,"US",apikey.Key);
    forecast = py.weather.parse_forecast_json(jsonData);
    forecast = convertData(forecast);
    
    Tforecast = forecast.temp;   
    dates = jsonencode(forecast.current_time);
    end
end 


function s = convertData(data)
% Convert from python types
s = struct(data);

s.current_time = string(cell(s.current_time))';
s.temp = jsondecode(char(s.temp));
% s.temp = string(cell(s.temp))'; %double(s.temp);   %time it

% not using, dont need rn, use to predict eventually

% s.speed = double(s.speed);   
% s.deg = double(s.deg);
% s.humidity = double(s.humidity);
% s.pressure = double(s.pressure);

% 
end
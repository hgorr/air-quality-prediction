function airQual = predictAirQual(data)
% PREDICTAIRQUAL Predict air quality, based on machine learning model
%
%#function CompactClassificationEnsemble

% Convert data types  
currentData = prepData(data);

% Load model and persist for future function calls
persistent model;

if isempty(model)
    mdl = load("airQualModel.mat");
    model = mdl.model;
end

% mdl = load("airQualModel.mat");
% model = mdl.model;

% Determine air quality
airQual = predict(model,currentData);

% Convert data type for use in Python
airQual = char(airQual);

end


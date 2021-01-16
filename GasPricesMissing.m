%% Compute correlation coefficients on data with missing values

%% IMPORT DATA from GasPrices.csv
gasPriceData = readtable('GasPrices.csv');

%Just using the gas prices, no years, use corrcoef to determine the matrix of pairwise correlation coefficients between each pair of columns and then visualize it using the imagesc function.
%% TODO: Find the correlation coefficient matrix for the original data and visualize it
% Create a numeric matrix containing all the price data
pricesRaw = gasPriceData{:,2:end};
cRaw = corrcoef(pricesRaw);

% Visualize the data with imagesc
imagesc(cRaw)

%Remove any rows that contain NaNs in gasPriceData as well as the year variable. 
%Then, determine the matrix of pairwise correlation coefficients between each pair of columns. 
%Visualize it using the imagesc function.
%% Find the correlation coefficient matrix for the data with NaNs removed and visualize it
% Create a numeric matrix containing all the price data
iNan = isnan(pricesRaw);
badRows = any(iNan,2);
pricesClean = pricesRaw(~badRows,:);
cClean = corrcoef(pricesClean);

% Visualize the data with imagesc
figure
imagesc(cClean)

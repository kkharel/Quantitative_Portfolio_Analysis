%% Interpolate currency exchange rate data

%% IMPORT DATA from CanadianExchange.csv
canEx = readtable('CanadianExchange.csv');
canEx.Dates = datetime(canEx.Dates);

%% TODO: Plot the Canadian dollar exchange rates using black points
plot(canEx.Dates,canEx.ExchangeRate,'k.','MarkerSize',6)

%% Linearly Interpolate the data from the first day to the last day in Dates with a step-size of one day.
%% Interpolate the missing values
% Create a duration vector containing the current dates in the plot 
origDays = days(canEx.Dates - canEx.Dates(1));

% Create a vector of days on which to interpolate
daysI = origDays(1):origDays(end);

% Interpolate the missing values
exI = interp1(origDays,canEx.ExchangeRate,daysI);

%% Plot the interpolated data in red
% Create the interpolated date vector from the interpolated day (duration) vector
datesI = canEx.Dates(1) + daysI;

hold on
plot(datesI,exI,'r')
xlabel('Dates')
ylabel('Canadian Exchange Rate')
grid on


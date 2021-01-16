FRED = Example_USEconData;
%%
% Transform raw data
Data = FRED;                        % Assign dates and raw data
Data.GDP = 100*log(FRED.GDP);       % GDP (output)
Data.GDPDEF = 100*log(FRED.GDPDEF); % GDP implicit price deflator
Data.COE = 100*log(FRED.COE);       % Compensation of employees (wages)
Data.HOANBS = 100*log(FRED.HOANBS); % Hours of all persons (hours)
Data.PCEC = 100*log(FRED.PCEC);     % Personal consumption expenditures (consumption)
Data.GPDI = 100*log(FRED.GPDI);     % Gross private domestic investment (investment)
%%
% Display model data
figure
subplot(2,2,1)
plot(Data.Time, [Data.GDP, Data.GDPDEF])
recessionplot
title('GDP & Price Deflator')
ylabel('Logarithm (x100)')
h = legend('GDP','GDPDEF','Location','Best');
h.Box = 'off';

subplot(2,2,2);
plot(Data.Time, [Data.PCEC Data.GPDI])
recessionplot
title('Consumption & Investment')
ylabel('Logarithm (x100)')
h = legend('PCEC','GPDI','Location','Best');
h.Box = 'off';

subplot(2,2,3)
plot(Data.Time, [Data.COE Data.HOANBS])
recessionplot
title('Wages & Hours')
ylabel('Logarithm (x100)')
h = legend('COE','HOANBS','Location','Best');
h.Box = 'off';

subplot(2,2,4)
plot(Data.Time, Data.FEDFUNDS)
recessionplot
title('Federal Funds')
ylabel('Percent')

%% Outline the Estimation Approach
%% Estimate the VEC Model
% Estimate cointegrating relation jci test
P = 2;                % The number of VEC(P-1) model lags
Y = Data.Variables;   % Extract all data from the timetable for convenience
[h,pValue,stat,cValue,mleHstar] = jcitest(Y, 'lags', P-1, 'Model', 'H*');
[h,pValue,stat,cValue,mleH1] = jcitest(Y, 'lags', P-1, 'Model', 'H1');

% lratiotest
r = 4;                   % Cointegrating rank
uLogL = mleHstar.r4.rLL; % Loglikelihood of the unrestricted H* model for r = 4
rLogL = mleH1.r4.rLL;    % Loglikelihood of the restricted H1 model for r = 4

[h,pValue,stat,cValue] = lratiotest(uLogL, rLogL, r)
%% jcon test
R = [zeros(1,size(Y,2))  1]';  % Constraint matrix
[h,pValue,stat,cValue] = jcontest(Y,r,'BCon',R,'Model','H*','Lags',P-1)

%% Estimate the VARX Model in Differences

[Mdl,se] = estimate(vecm(size(Y,2),r,P-1), Y, 'Model', 'H1');
toFit = vecm(Mdl.NumSeries, Mdl.Rank, Mdl.P - 1);

toFit.Constant(abs(Mdl.Constant ./ se.Constant) < 2) = 0;
toFit.ShortRun{1}(abs(Mdl.ShortRun{1} ./ se.ShortRun{1}) < 2) = 0;
toFit.Adjustment(abs(Mdl.Adjustment ./ se.Adjustment) < 2) = 0;
Fit = estimate(toFit, Y, 'Model', 'H1');

B = [Fit.Cointegration ; Fit.CointegrationConstant' ; Fit.CointegrationTrend'];
figure
plot(Data.Time, [Y ones(size(Y,1),1) (-(Fit.P - 1):(size(Y,1) - Fit.P))'] * B)
recessionplot
title('Cointegrating Relations')

%% Impulse Response Analysis
horizon = 40;

VAR = varm(Fit);
IRF = armairf(VAR.AR, {}, 'InnovCov',  VAR.Covariance, 'NumObs', horizon);

h = figure;
iSeries = 1;            % Column 1 is associated with GDP series
for i = 1:Mdl.NumSeries
    subplot(Mdl.NumSeries,1,i)
    plot(IRF(:,i,iSeries))
    title("GDP Impulse Response to " + Data.Properties.VariableNames(i))
end

screen = get(h,'Parent');
set(h,'Position',[h.Position(1) screen.MonitorPositions(4)*0.1 h.Position(3) screen.MonitorPositions(4)*0.8]);

%% Compute Out-of-Sample Forecasts and Assess Forecast Accuracy
Y = Data;                   % Work directly with the timetable
T0 = datetime(1976,12,31);  % Initialize forecast origin (31-Dec-1976 = (1976,12,31) triplet)
T = T0;
horizon = 4;                % Forecast horizon in quarters (4 = 1 year)
numForecasts = numel(Y.Time(timerange(T,Y.Time(end),'closed'))) - horizon;
yForecast = nan(numForecasts, horizon, Mdl.NumSeries);

for t = 1:numForecasts
%
%   Get the end-of-quarter dates for the current forecast origin.
%
    quarterlyDates = timerange(Y.Time(1), T, 'closed');
%
%   Estimate the VEC model.
%
    Fit = estimate(toFit, Y(quarterlyDates,:).Variables, 'Model', 'H1');
%
%   Forecast the model at each quarter out to the forecast horizon.
%
%   Store the forecasts for the current origin (T) as a 3-D array in which
%   the 1st page stores all forecasts for the 1st series (GDP), the 2nd page
%   stores all forecasts for the 2nd series (GDPDEF), and so forth. This
%   storage convention facilitates the access of data from the timetable
%   of forecasts created below.
%
    yForecast(t,:,:) = forecast(Fit, horizon, Y(quarterlyDates,:).Variables);
%
%   Update the forecast origin to include the data of the next quarter.
%
    T = dateshift(T, 'end', 'quarter', 'next');
end
originDates = dateshift(T0, 'end', 'quarter', (0:(numForecasts-1))');

forecastDates = NaT(numForecasts,horizon);
for i = 1:horizon
    forecastDates(:,i) = dateshift(originDates, 'end', 'quarter', i);
end

Forecast = timetable(forecastDates,'RowTimes',originDates, 'VariableNames', {'Times'});
for i = 1:size(Y,2)
    Forecast.(Y.Properties.VariableNames{i}) = yForecast(:,:,i);
end
forecastRealGDP = Forecast.GDP(:,4) - Forecast.GDPDEF(:,4);
realGDP = Y(Forecast.Times(:,4),:).GDP - Y(Forecast.Times(:,4),:).GDPDEF;

figure
subplot(2,1,1)
plot(Forecast.Times(:,4), forecastRealGDP, 'r')
hold on
plot(Forecast.Times(:,4), realGDP, 'b')
title('Real GDP vs. Forecast: 4-Quarters-Ahead')
ylabel('USD Billion')
recessionplot
h = legend('Forecast','Actual','Location','Best');
h.Box = 'off';

subplot(2,1,2)
plot(Forecast.Times(:,4), forecastRealGDP - realGDP)
title('Real GDP Forecast Error: 4-Quarters-Ahead')
ylabel('USD Billion')
recessionplot

%% Analysis Coronavirus Crisis of 2020: Forecasting Real GDP
horizon = 3;  % 3 quarters = 3 years (Table 3 of Smets and Wouters <docid:econ_ug#mw_338db74a-1baa-4a34-88a3-849284bf115a>)

T = datetime(2019,12,31);  % Forecast origin just prior to the crisis (31-Dec-2019 = (2007,12,31) triplet)
Fit = estimate(toFit, Y(timerange(Y.Time(1),T,'closed'),:).Variables, 'Model', 'H1');
[yForecast, yMSE] = forecast(Fit, horizon, Y(timerange(Y.Time(1),T,'closed'),:).Variables);

sigma = zeros(horizon,1);  % Forecast standard errors
for i = 1:horizon
    sigma(i) = sqrt(yMSE{i}(1,1) - 2*yMSE{i}(1,2) + yMSE{i}(2,2));
end

forecastDates = dateshift(T, 'end', 'quarter', 1:horizon);
figure
plot(forecastDates, (yForecast(:,1) - yForecast(:,2)) + sigma, '-.r')
hold on
plot(forecastDates,  yForecast(:,1) - yForecast(:,2), 'r')
plot(forecastDates, (yForecast(:,1) - yForecast(:,2)) - sigma, '-.r')
plot(forecastDates, Y(forecastDates,:).GDP - Y(forecastDates,:).GDPDEF, 'b')
title("Real GDP vs. 12-Q Forecast: Origin = " + string(T))
ylabel('USD Billion')
recessionplot
h = legend('Forecast +1\sigma', 'Forecast', 'Forecast -1\sigma', 'Actual', 'Location', 'Best');
h.Box = 'off';
%%
% The estimated model fails to anticipate the dramatic economic downturn. Given the magnitude of the crisis, the failure to capture the extent of the recession is, perhaps, somewhat unsurprising.




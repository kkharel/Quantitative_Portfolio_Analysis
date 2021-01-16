%Fit a quadratic polynomial to the data, and add a red curve to the plot 
%of the data that goes to 15 months. Predict the rate of maturity for a 
%15-month loan and name it rate15.

%% spotCurve.m
% Fit data to spot curve data

%% Import Data
% Data is imported into a table named spotRates with two variables:
% maturity and spotrate
spotRates = readtable('spotRates.csv');

%% Plot the spot curve
figure
plot(spotRates.maturity,spotRates.spotrate,'o')
xlabel('Loan maturity (months)')
ylabel('Spot rate')
hold on

%% TODO: Fit a quadratic polynomial to the data
c = fitlm(spotRates,'quadratic');

%% TODO: Add the curve to the plot of the data
trendLine = predict(c,(1:15)');
plot(1:15,trendLine,'r')

%% TODO: Predict the rate for a maturity of 15-months called rate15
rate15 = trendLine(end);
title(['Quadratic model 15 month rate is ',num2str(rate15)])

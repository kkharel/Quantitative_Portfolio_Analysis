%The table returns is imported into MATLAB, where the first column contains
%dates, Dates, the second column contains the DAX return values, DAX, and
%the subsequent columns contain German stock return values.

%% stocksDe.m - financial multivariate stats exercise

%% Import table of returns
returns = readtable('germanStocks.csv');

%% Plot original data
subplot(2,1,1)
plot(returns.Dates(end-50:end),returns.DAX(end-50:end))
hold on
grid on
title({'Deutscher Aktienindex (DAX) Returns';'German Stock Index Return Values'})

%% Set-up dimensions for Monte-Carlo Simulations
nSteps = 20;            % Number of steps into the future
nExperiments = 2;       % Number of different experiments to run

%% TODO: Generate random numbers from the information in DAX
tFit = fitdist(returns.DAX,'tLocationScale');
simReturns = random(tFit,nSteps,nExperiments);

%% Plot the returns
futureDates = returns.Dates(end) + days(1:nSteps);
plot([returns.Dates(end) futureDates],[returns.DAX(end)*ones(1,nExperiments) ; simReturns])
hold off

%% Plot the Index Values
lastDAX = 6147.97;
predictions = ret2tick(simReturns,'StartPrice',lastDAX);
subplot(2,1,2)
plot([returns.Dates(end) futureDates],predictions)
grid on
title({'Deutscher Aktienindex (DAX)';'German Stock Index'})

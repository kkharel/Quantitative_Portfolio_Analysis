%Use the FTSE return values in FTSEreturns to create a t Location-Scale 
%probability distribution object. Then modify the code so that the random 
%numbers generated use this fit object

%% Import data and compute returns
FTSEtable = readtable('FTSEavgs.csv');
FTSEtable.Dates = datetime(FTSEtable.Dates);
dys = days(datetime(FTSEtable.Dates) - datetime(FTSEtable.Dates(1)));
FTSEreturns = tick2ret(FTSEtable.FTSE,dys);

%% TODO: Fit a t scale-location distribution
tFit = fitdist(FTSEreturns,'tlocationscale');

%% Monte-Carlo Simulations for a t distribution
nSteps = 10;       % Number of steps into the future
nExp = 5e3;        % Number of random experiments to run

%% TODO: Modify simReturns to generate random numbers from the fit
simReturns = random(tFit,nSteps,nExp);

predictions = ret2tick(simReturns,FTSEtable.FTSE(end));
quantileCurves = quantile(predictions,[0.01 0.05 0.5 0.95 0.99],2);

%% Plot the returns
figure
subplot(2,1,1)
plot(FTSEtable.Dates,FTSEtable.FTSE,'LineWidth',2)
title('FTSE Closing Value')
xlabel('Date')
grid on
hold on
plot(FTSEtable.Dates(end) + (0:nSteps),quantileCurves,'r')
legend('Historical Data','Future Predictions','Location','NW')
hold off

subplot(2,1,2)
histogram(predictions(end,:),'Normalization','pdf')
xlabel('FTSE Closing Value')
title('Distrubtion of Simulated Values at Dec. 31, 2008')

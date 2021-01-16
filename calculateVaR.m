function var = calculateVaR(stock)

% Calculate the daily log returns and the statistics
stockReturns = diff(log(stock));
mu = mean(stockReturns);
sigma = std(stockReturns);

% Simulate prices for 22 days in future based on GBM
deltaT = 1;
S0 = stock(end);
epsilon = randn(22,200);
factors = exp((mu-sigma^2/2)*deltaT + sigma*epsilon*sqrt(deltaT));
lastPriceVector = ones(1,200)*S0;
factors2 = [lastPriceVector;factors];
paths = cumprod(factors2);

% Extract final prices
finalPrices = paths(end,:);

% Calculate returns
possibleReturns = log(finalPrices) - log(S0);

% Calculate the VaR
var = prctile(possibleReturns,5);


% Load data
stockPrices = readtable('stockData.csv');
stockInfo = readtable('stockInfo.csv');

% Determine economy's Performance
movAvgShort = movavg(stockPrices.FTSE,'exponential',3);
movAvgLong = movavg(stockPrices.FTSE,'exponential',5);
MACD = movAvgShort - movAvgLong;
econPerformance = zeros(length(MACD),1);
econPerformance(MACD >= 5) = 1;
econPerformance(MACD <= -5) = -1;
stockPrices.econPerformance = econPerformance;

% Examine the variable stockPrices - the momentum on Nov-6-1986 is 1 i.e., 'up'.
% Extract the stock codes of all the 'upcycle' stocks.
upcycleIdx = strcmp(stockInfo.Classification,'upcycle');
stocksToBuy = stockInfo{upcycleIdx,'Code'};

% Extract the corresponding prices
stocksToBuyPrices = stockPrices{:,stocksToBuy};

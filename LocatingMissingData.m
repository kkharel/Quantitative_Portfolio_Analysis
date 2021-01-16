stockData = readtable('SPY.csv');
%% You can use the height function to find the number of observations in a table.
totRows = height(stockData)

%% Try to create a variable named badrows containing a value of true if a row in stockData contains a missing value, and false otherwise.
badrows = any(ismissing(stockData),2)

%% Try to create a variable named dataNM that has only the complete rows in stockData.
dataNM = stockData(~badrows,:)

%% Try to create a variable named totRowsNM containing the number of observations in dataNM.
totRowsNM = height(dataNM)

%% Try to create a variable named avgGfs containing the average value of dataNM.AdjClose.
avgGfs = mean(dataNM.AdjClose) 




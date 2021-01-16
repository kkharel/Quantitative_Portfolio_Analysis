function y = tableInterp(y)

% Create a vector of evenly spaced x-values the same length as y
x = (1:length(y))';

% Create a logical vector with true at the location of non-missing values
idx = ~isnan(y);

% Extract non-missing values
xClean = x(idx);
yClean = y(idx);

% Use this index to extract non-missing data and interpolate the missing
% values
y = interp1(xClean,yClean,x,'spline','extrap');

%Try to use nnz with the ismissing function to determine how many missing values 
% there are in the table t. Assign the result to a scalar named numNan.
numNan = nnz(ismissing(t))

%Try to create a table named tInterp that replaces the missing values in t
% with interpolated values.
tInterp = varfun(@tableInterp,t)

% This script calculates amortization schedule of a fixed-rate mortgage

% Define the parameters
loanAmount = 440000;
monthlyRate = 0.04/12; % 0.04 is the annual rate
numPeriods = 12*30; % loanTerm is 30 years

% Calculate the amortization schedule
[Principle,Interest,Balance,Payment] = amortize(monthlyRate,numPeriods,loanAmount);

% Visualize the payments
plot(Balance,'LineWidth',1.5)
hold on
plot(cumsum(Principle),'LineWidth',1.5)
plot(cumsum(Interest),'LineWidth',1.5)
legend('Remaining Balance','Accumulated Principle Paid','Accumulated Interest Paid')
title('Amortization Schedule')
hold off

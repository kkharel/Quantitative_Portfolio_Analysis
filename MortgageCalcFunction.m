function Payment = MortgageCalcFunction(loanAmount,loanTerm,annualRate)
% This function calculates amortization schedule of a fixed-rate mortgage

% Define the parameters
monthlyRate = annualRate/12;
numPeriods = 12*loanTerm;

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

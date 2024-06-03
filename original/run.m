close all;

figure(1);
title('Price of Electricity');
xlabel('Year');
ylabel('Price ($)');
hold on

figure(2);
title('Price of CO2');
xlabel('Year');
ylabel('Price ($)');
hold on

for ii = 1:100
  [P_e, P_c] = simu(37, 4.5);

  figure(1);
  plot(P_e);

  figure(2);
  plot(P_c);
end

% Construct a strategy
% Action costs
cost_noccs = 1664240721; % Cost of capital without CCS
cost_addccs = 849822693; % Cost of capital to add CCS 
cost_switch = .01 * (cost_noccs + cost_addccs); % Switching cost ($)

[strat, inits] = optimize(10, 20, 60, 10, 0, 150, 20, cost_noccs, ...
                          cost_addccs, cost_switch);

allprofits = [];
alltimings = [];
for ii = 1:400
  [P_e, P_c] = simu(37, 4.5);
  [profits, invests] = simustrat(strat, inits, P_e, P_c, 20, 60, 10, ...
                                 0, 150, 20, cost_noccs, cost_addccs, ...
                                 cost_switch);
  allprofits(ii) = sum(profits);
  alltimings(ii) = find(invests == cost_addccs);
end

hist(allprofits, 15);
title('Distribution of Profits');

hist(alltimings, 1:50);
title('Distribution of Investment in CCS');
function [P_f] = simu(T, P_f0, process, sigma)
% Simulate without a strategy, for T time steps

P_f = [P_f0];

for t = 1:(T-1)
  [P_f(t+1)] = simustep(P_f(t), process, sigma);
end

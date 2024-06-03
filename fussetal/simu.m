function [P_e, P_c] = simu(P_e0, P_c0)

P_e = [P_e0];
P_c = [P_c0];

for t = 1:49
  [P_e(t+1), P_c(t+1)] = simustep(P_e(t), P_c(t));
end

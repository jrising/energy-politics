function [profits, invests] = simustrat(strat, inits, P_e, P_c, P_e_min, ...
                                    P_e_max, E, P_c_min, P_c_max, ...
                                    C, cost_noccs, cost_addccs, cost_switch)
% strat is a TxXxExC matrix
%   T = 50 (for t in 1:50)
%   X = 3 (for x in [noCCS offCCS onCCS])
%   E, C are discretized versions of P_e and P_c respectively
% inits is ExC, an initial investment of noCCS (1), offCCS (2), onCCS (3)

init_costs = [cost_noccs (cost_noccs + cost_addccs)];

profits = zeros(1, 50);
invests = zeros(1, 50);

% STEP 1: What kind of powerplant should we build?
Ei = discrete(P_e(1), P_e_min, P_e_max, E);
Ci = discrete(P_c(1), P_c_min, P_c_max, C);

x = inits(Ei, Ci);
m = min(x, 2);

invests(1) = init_costs(m);
profits(1) = profit(m, P_e(1), P_c(1), invests(1));

% Costs of actions, with state given by row
% actions: [noCCS->noCCS offCCS->offCCS onCCS->onCCS; 
%           noCCS->onCCS offCCS->onCCS onCCS->offCCS]
m1 = [1 1 2];
x2 = [1 2 3; 3 3 2];
ca = [0 0 0; cost_addccs cost_switch cost_switch];

xx = [x];
aa = [];

for t = 2:50
  Ei = discrete(P_e(t), P_e_min, P_e_max, E);
  Ci = discrete(P_c(t), P_c_min, P_c_max, C);

  a = strat(t-1, x, Ei, Ci);
  aa(t-1) = a;
  
  invests(t) = ca(a, x);
  profits(t) = profit(m1(x), P_e(t), P_c(t), invests(t));
  
  x = x2(a, x);
  xx(t) = x;
end

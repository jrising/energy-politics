function prefstrat = preferred_strategies(S, C, D_C_min, D_C_max, D, F, Q_const, ...
                                          lambdas, ideals, util_type, estrat)
%%% Code to get the Strategies that maximize instantaneous payoff to compare to
%%% dynamic strategy over time

prefstrat = zeros(S-1, C, F, 2);

S_C = linspace(0, 1, C);
D_C = [0 linspace(D_C_min, D_C_max, D)/C];

[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);
for t = 1:S-1
  for Fi = 1:F
    eactions= squeeze(estrat(t, state1, :)); 
    eideal = reshape(S_C(state1(:)) + D_C(eactions(:, Fi)), size(state1));
    payoff_now1 = payoff(S_C(state1) + q_c/Q_const, lambdas(1), ...
                         ideals(1), reshape(eideal, size(state1)), util_type); 
    payoff_now2 = payoff(S_C(state1) + q_c/Q_const, lambdas(2), ...
                         ideals(2), reshape(eideal, size(state1)), util_type);                       
    [val1 prefstrat(t, :, Fi, 1)] = max(payoff_now1);    
    [val2 prefstrat(t, :, Fi, 2)] = max(payoff_now2);
  end
end
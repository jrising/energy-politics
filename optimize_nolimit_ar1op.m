function [strat_1, strat_2, VV2_1, VV2_2] = optimize_nolimit_ar1op(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, lambdas,  ideals, discounts, util_type, ...
                                                  termlen, voteModel, vmArgs, estrat, prefstrats, sigma, process)
% N = number of monte carlo projections
% strat_* are SxCxFx2 matrices; values are campaigned clean shares
%   S = planning horizon (timesteps)
%   C is discretized version of the clean energy share
%   F is discretized versions of P_f
%   2 for last year's favorite (winner of the mock election)
% values are 1 (no change), 2-D+1 (change in share on next period)

strat_1 = zeros(S-1, C, F, 2);
strat_2 = zeros(S-1, C, F, 2);

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

% STEP 1: Calculate V[S] under every scenario
% VV is CxFx2x2 states of world x 2 perspectives
VV2_1 = zeros(C, F, 2, 2);
VV2_2 = zeros(C, F, 2, 2);

% STEP 2: Determine optimal action in t = S-1 and back
[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);

dc = [0 linspace(D_C_min, D_C_max, D)/C];

for t = (S-1):-1:1
  disp(t);
  is_election = mod(t, termlen) == 0;
  eactions = squeeze(estrat(t, state1, :));  % retrieves the best economic action for each of the 20 states (as indices).
  prefactions = squeeze(prefstrats(t, state1, :, :));

  [VV2_1, VV2_2, strat_1(t, :, :, :), strat_2(t, :, :, :)] ...
      = optimize_step_ar1op(VV2_1, VV2_2, N,  C, D_C_min, D_C_max, P_f_min, P_f_max, ...
                            F, state1, state2a, state2b, xprob2, dc, q_c, q_f, ...
                            Q_const, lambdas, ideals, discounts, util_type, ...
                            voteModel, vmArgs, is_election, eactions, prefactions, sigma, ...
                            process);
end

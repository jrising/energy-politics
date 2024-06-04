function [strat_1, strat_2] = optimize_limit(N, S, horizon, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                             Q_const, lambdas, ideals, discounts, util_type, termlen, ...
                                             polModel, voteModel, vmArgs, estrat, process)
% N = number of monte carlo projections
% horizon = planning horizon
% strat_* are (S-1)xCxF matrices; values are campaigned clean shares
%   S = planning horizon (timesteps)
%   C is discretized version of the clean energy share
%   F is discretized versions of P_f
% values are 1 (no change), 2-D+1 (change in share on next period)

strat_1 = zeros(S-1, C, F);
strat_2 = zeros(S-1, C, F);

% VV is a Cx2F matrix

discount = .05; % discount rate

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);

dc = [0 linspace(D_C_min, D_C_max, D)/C];

for ss = (S-1):-1:1
  disp(ss);
  % STEP 1: Calculate V[S] under every scenario
  % VV is CxFx2 states of world x 2 perspectives
  VV2_1 = repmat(0, [C F 2]);
  VV2_2 = repmat(0, [C F 2]);

  for rr = min(S-1, ss+horizon):-1:ss
    is_election = mod(rr, termlen) == 0;
    eactions = squeeze(estrat(rr, state1, :));  % retrieves the best economic action for each of the 20 states (as indices).

    if polModel == 'retro'
      [VV2_1, VV2_2, strat_1(rr, :, :), strat_2(rr, :, :)] = optimize_step_retro(VV2_1, VV2_2, N, C, P_f_min, P_f_max, ...
                                                        F, state1, state2a, state2b, xprob2, dc, q_c, q_f, ...
                                                        Q_const, lambdas, ideals, discounts, util_type, ...
                                                        voteModel * is_election, vmArgs, eactions, process);
    elseif polModel == 'coghi'
      [VV2_1, VV2_2, strat_1(rr, :, :), strat_2(rr, :, :)] = optimize_step_coghi(VV2_1, VV2_2, N, C, P_f_min, P_f_max, ...
                                                        F, state1, state2a, state2b, xprob2, dc, q_c, q_f, ...
                                                        Q_const, lambdas, ideals, discounts, util_type, ...
                                                        voteModel * is_election, vmArgs, eactions, process, 2 * is_election);
    else
      error('Unknown political model');
    end
  end
end

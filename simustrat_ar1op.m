function [s_c] = simustrat_ar1op(S, C, D_C_min, D_C_max, D, strat, strat_other, estrat, ...
                                 P_f_min, P_f_max, F, P_f, s_c0, voteModel, vmArgs)
% strat is the party's true strategy [SxCxFx2]
% strat_other is the opposition party's apolitical strategy (same
%   as the one fed into optimize_nolimit_ar1op). [SxCxF]

D_C = [0 linspace(D_C_min, D_C_max, D)/C];

s_c = [s_c0];
d_c = [];
prob_last_favorite = 1;

for t = 1:S-1
  Fi = discrete(P_f(t), P_f_min, P_f_max, F);
  Ci = discrete(s_c(t), 0, 1, C);

  d_c(t) = prob_last_favorite * D_C(strat(t, Ci, Fi, 2)) + ...
           (1 - prob_last_favorite) * D_C(strat(t, Ci, Fi, 1));
  s_c(t+1) = s_c(t) + d_c(t);
  
  s_c_other = s_c(t) + strat_other(t, Ci, Fi);
  s_c_eideal = s_c(t) + estrat(t, Ci, Fi);

  prob_current_favorite = election(voteModel, true, s_c(t), s_c(t+1), s_c_other, s_c_eideal, vmArgs(1:end-1));
  prob_last_favorite = vmArgs(end) * prob_current_favorite + (1 - vmArgs(end)) * prob_last_favorite;
end

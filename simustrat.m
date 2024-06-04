function [s_c, d_c_b, d_c_g, elected] = simustrat(S, R, C, D_C_min, D_C_max, D, stratb, stratg, ...
                                        P_f_min, P_f_max, F, P_f, ...
                                        s_c0, elected0, election_rule, args)

% elected0 is the initial party in power; 0 for brown party (with strategy stratb), 1 for
%   green party (with strategy stratg), and a fractional amount for a linear compromise
% election_rule specifies how parties are elected:
%   0 - never change the party
%   1 - randomly choose a new party (with probably p) every 4 years
%   2 - take the election winnners from args
% changes: added a time series for d_c_b, d_c_g and elected, also added
% variable odds

D_C = [0 linspace(D_C_min, D_C_max, D)/C];

s_c = [s_c0];
d_c = [];
elected = elected0;

for t = 2:S
  if election_rule == 1 && mod(t-1, 4) == 0
    elected(t) = binornd(1,1-args);
  elseif election_rule == 2 && mod(t-1, 4) == 0
    elected(t) = args((t-1) / 4);
  else
    elected(t) = elected(t-1);
  end
    
  Fi = discrete(P_f(t-1), P_f_min, P_f_max, F);
  Ci = discrete(s_c(t-1), 0, 1, C);


  d_c_b(t) = D_C(stratb(mod(t-2, R)+1, Ci, Fi));
  d_c_g(t) = D_C(stratg(mod(t-2, R)+1, Ci, Fi));
  d_c(t-1) = (1 - elected(t)) * d_c_b(t) + elected(t) * d_c_g(t);
    
  s_c(t) = s_c(t-1) + d_c(t-1);
end

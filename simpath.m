function [path, green_actions, brown_actions]=path(strat1, strat2, inpower, P_f, P_f_min, P_f_max, F, C, D_C_min, D_C_max, D)
D_C = [0 linspace(D_C_min, D_C_max, D)/C];
cc = .143;
ac = 0;
for jj = 2:50
  before = discrete(cc(jj-1), 0, 1, C);
  Fi = discrete(P_f(jj), P_f_min, P_f_max, F);
  if inpower(jj)==1
      ac(jj) = strat1(jj-1, before, Fi);
      green_actions = 0;
      brown_actions = D_C(ac(jj));
  elseif inpower(jj)==2
      ac(jj) = strat2(jj-1, before, Fi);
      green_actions = D_C(ac(jj));
      brown_actions = 0;
  end
  cc(jj) = cc(jj-1) + D_C(ac(jj));
end
  path=cc; 
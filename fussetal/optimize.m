function [strat, inits] = optimize(nn, P_e_min, P_e_max, E, P_c_min, ...
                                   P_c_max, C, cost_noccs, cost_addccs, ...
                                   cost_switch)
% strat is a TxXxExC matrix
%   T = 50 (for t in 1:50)
%   X = 3 (for x in [noCCS offCCS onCCS])
%   E, C are discretized versions of P_e and P_c respectively
%   values of 1 no change, 2 mean add-CCS/switch
% inits is ExC, an initial investment of noCCS (1), offCCS (2), onCCS (3)

strat = zeros(49, 3, E, C);

% VV is a XxExC matrix

discount = .05; % discount rate

P_e = linspace(P_e_min, P_e_max, E);
P_c = linspace(P_c_min, P_c_max, C);

% STEP 1: Calculate V_50 under every scenario
VV2 = zeros(3, E, C);
m = [1 1 2]; % CCS operational?
for Ei = 1:E
  for Ci = 1:C
    VV2(:, Ei, Ci) = profit(m, P_e(Ei), P_c(Ci), zeros(1, 3));
  end
end

% STEP 2: Determine optimal action in t = 49 and back

% Costs of actions, with state given by row
% actions: [noCCS->noCCS offCCS->offCCS onCCS->onCCS; 
%           noCCS->onCCS offCCS->onCCS onCCS->offCCS]
m1 = [1 1 2; 1 1 2];
%m2 = [1 1 2; 2 2 1];
x2 = [1 2 3; 3 3 2];
ca = [0 0 0; cost_addccs cost_switch cost_switch];

for t = 49:-1:1
  disp(t);
  VV1 = zeros(3, E, C);

  for Ei = 1:E
    for Ci = 1:C
      sums = zeros(6, 1);
      
      for ii = 1:nn
        [P_e2, P_c2] = simustep(P_e(Ei), P_c(Ci));
        
        Ei2 = discrete(P_e2, P_e_min, P_e_max, E);
        Ci2 = discrete(P_c2, P_c_min, P_c_max, C);
        
        sums = sums(:) + VV2(x2, Ei2, Ci2);
      end

      profit_later = reshape(sums, 2, 3) / nn;
      profit_now = profit(m1, P_e(Ei), P_c(Ci), ca);

      [VV1(:, Ei, Ci), strat(t, :, Ei, Ci)] = ...
          max(profit_now + exp(-discount) * profit_later);
    end
  end

  VV2 = VV1;
end

inits = zeros(E, C);
cost_withccs = cost_noccs + cost_addccs;
for Ei = 1:E
  for Ci = 1:C
    [vv, inits(Ei, Ci)] = max(VV2(:, Ei, Ci) - ...
                              [cost_noccs cost_withccs cost_withccs]');
  end
end

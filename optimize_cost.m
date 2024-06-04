function [strat] = optimize_cost(N, S, C, D_C_min, D_C_max, D, ...
                                 P_f_min, P_f_max, F, Q_const, alpha_wind, alpha_solar, process, declining, fuel_sigma, e_of_scale)
% N = number of monte carlo projections
% strat is a SxCxF matrix
%   S = planning horizon (timesteps)
%   C is discretized version of the clean energy share
%   F is discretized versions of P_f
% values are 1 (no change), 2-D+1 (change in share on next period)

strat = zeros(S-1, C, F);

% VV is a CxF matrix

discount = .05; % discount rate

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

% STEP 1: Calculate V[S] under every scenario
VV2 = zeros(C, F);
for Fi = 1:F
  % Need to divide by 1 - e^-discount for asymptotic (for delayed cost)
  VV2(:, Fi) = ecost(S_C, Q_const, 0, 0, P_f(Fi), alpha_wind, alpha_solar, declining, e_of_scale) * (1/(discount));% (1/discount-1/discount*exp(-discount*10)) ;  % cost from maintenance and fuel only
  %since in the last period, one can no longer invest.
end

% STEP 2: Determine optimal action in t = S-1 and back
[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);

for t = (S-1):-1:1
  disp(t);
  VV1 = zeros(C, F);
  
  for Fi = 1:F
    sums1 = zeros(size(state2a));
    sums2 = zeros(size(state2b));

    for ii = 1:N
      [P_f2] = simustep(P_f(Fi), process, fuel_sigma);
      Fi2 = discrete(P_f2, P_f_min, P_f_max, F);

      sums1 = sums1(:) + VV2((Fi2-1)*C + state2a(:));
      sums2 = sums2(:) + VV2((Fi2-1)*C + state2b(:));
    end

    ecost_later1 = reshape(sums1, size(state2a)) / N;
    ecost_later2 = reshape(sums2, size(state2b)) / N;
    later = (xprob2 .* ecost_later2 + (1 - xprob2) .* ecost_later1);
    ecost_now = ecost(S_C(state1), Q_const, q_c, q_f, P_f(Fi), alpha_wind, alpha_solar, declining, e_of_scale); % M added alpha_wind,alpha_solar as arguments
    values = ecost_now + exp(-discount) * later;

    [VV1(:, Fi), strat(t, :, Fi)] = min(values);
  end
  
  VV2 = VV1;
end

function [strat_1, strat_2] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                            Q_const, lambdas, ideals, discounts, util_type, termlen, p_b, estrat, process, sigma)
                       
% N = number of monte carlo projections
% strat_* are SxCxF matrices; values are campaigned clean shares
%   S = planning horizon (timesteps)
%   C is discretized version of the clean energy share
%   F is discretized versions of P_f
% values are 1 (no change), 2-D+1 (change in share on next period)

strat_1 = zeros(S-1, C, F);
strat_2 = zeros(S-1, C, F);

% VV is a Cx2F matrix

%discount = .05; % discount rate

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

% STEP 1: Calculate V[S] under every scenario
% VV is CxFx2 states of world x 2 perspectives
%VV2_1 = repmat(payoff(S_C', lambdas(1), ideals(1), 1), [1 F 2]);
%VV2_2 = repmat(payoff(S_C', lambdas(2), ideals(2), 1), [1 F 2]);
VV2_1 = repmat(0, [C F 2]);
VV2_2 = repmat(0, [C F 2]);

% STEP 2: Determine optimal action in t = S-1 and back
[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);

dc = [0 linspace(D_C_min, D_C_max, D)/C];

for t = (S-1):-1:1
  disp(t);
  VV1_1 = zeros(C, F, 2);
  VV1_2 = zeros(C, F, 2);

  for Pi = 1:2  % Pi stands for party, Pi=1 is the brown party and Pi=2 is the green party
    for Fi = 1:F  % indices for position of the current state in the coal price space
      sums_a1 = zeros(size(state2a));
      sums_b1 = zeros(size(state2b));
      sums_a2 = zeros(size(state2a));
      sums_b2 = zeros(size(state2b));

      for ii = 1:N
        [P_f2] = simustep(P_f(Fi), process, sigma);
        Fi2 = discrete(P_f2, P_f_min, P_f_max, F);  % says in which bin of the discretized coal price space P_f2 falls
        if mod(t, termlen) == 0   % election period
          Pi2 = (binornd(1,1-p_b)) + 1; %3 - Pi;
        else
          Pi2 = Pi;
        end
      
        sums_a1 = sums_a1(:) + VV2_1((Pi2-1)*F*C + (Fi2-1)*C + state2a(:)); 
        sums_b1 = sums_b1(:) + VV2_1((Pi2-1)*F*C + (Fi2-1)*C + state2b(:));
        sums_a2 = sums_a2(:) + VV2_2((Pi2-1)*F*C + (Fi2-1)*C + state2a(:));
        sums_b2 = sums_b2(:) + VV2_2((Pi2-1)*F*C + (Fi2-1)*C + state2b(:));
      end

      value_later_a1 = reshape(sums_a1, size(state2a)) / N;
      value_later_b1 = reshape(sums_b1, size(state2b)) / N;
      value_later_a2 = reshape(sums_a2, size(state2a)) / N;
      value_later_b2 = reshape(sums_b2, size(state2b)) / N;
      later_1 = (xprob2 .* value_later_b1 + (1 - xprob2) .* value_later_a1);
      later_2 = (xprob2 .* value_later_b2 + (1 - xprob2) .* value_later_a2);
      
      eaction = estrat(t, state1, Fi);  % retrieves the best economic action for each of the 20 states (as indices).
      eideal = S_C(state1(:)) + dc(eaction); %ideal share, economically

      [nrow, ncol] = size(state1);
      
      if Pi == 1
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(1), ...
                            ideals(1), reshape(eideal, size(state1)), util_type);  % the current state plus the marginal share increase determines the payoff

        values = payoff_now + exp(-discounts(1)) * later_1;  % 101x20 matrix for actions x energy states
        [VV1_1(:, Fi, Pi), strat_1(t, :, Fi)] = max(values); % gives the maximum value and the argmax action
        
        choice_indexes = ((1:C)-1) * nrow + strat_1(t, :, Fi);
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(2), ...
                              ideals(2), eideal(choice_indexes), util_type);

        VV1_2(:, Fi, Pi) = payoff_other + exp(-discounts(2)) * later_2(choice_indexes);
      else
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(2), ...
                              ideals(2), reshape(eideal, size(state1)), util_type);

        values = payoff_now + exp(-discounts(2)) * later_2;
        [VV1_2(:, Fi, Pi), strat_2(t, :, Fi)] = max(values);

        choice_indexes = ((1:C)-1) * nrow + strat_2(t, :, Fi);
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(1), ...
                              ideals(1), eideal(choice_indexes), util_type);

        VV1_1(:, Fi, Pi) = payoff_other + exp(-discounts(1)) * later_1(choice_indexes);
      end
    end
  end
  
  VV2_1 = VV1_1;
  VV2_2 = VV1_2;
end

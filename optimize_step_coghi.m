function [VV1_1, VV1_2, strat_1, strat_2] = optimize_step_coghi(VV2_1, VV2_2, C, D_C_min, D_C_max,P_f_min, P_f_max, F, state1, state2a, ...
                                                  state2b, xprob2, dc, q_c, Q_const, lambdas, ideals, ...
                                                  discounts, util_type, voteModel, vmArgs, eactions, prefactions, stratrecurse)
                                             
% Perform a single timestep under the recursive political system
%
% VV2_1 and VV2_2 are the future valuations of all states of the
%   world for parties 1 and 2
% C, P_f_min, P_f_max, F, and Q_const are normal run parameters
% state1, state2a, state2b, xprob2, q_c, and q_f are from make_actions
% dc is (possibly fractional) state changes from each action
% lambdas, ideals, discounts, and util_type define party preferences
% voteModel and vmArgs define the election process
% eactions are the economically optimal actions under each state
% process defines the simustep Monte Carlo algorithm

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

VV1_1 = zeros(C, F, 2);
VV1_2 = zeros(C, F, 2);
strat_1 = zeros(C, F);
strat_2 = zeros(C, F);

if voteModel == 0 % non-election period
  for Pi = 1:2  % Pi stands for party, Pi=1 is the brown party and Pi=2 is the green party
    for Fi = 1:F  % indices for position of the current state in the coal price space
      Fi2 = Fi;
      Pi2 = Pi;
      
      sums_a1 = VV2_1((Pi2-1)*F*C + (Fi2-1)*C + state2a(:)); % values for party 1
      sums_b1 = VV2_1((Pi2-1)*F*C + (Fi2-1)*C + state2b(:));
      sums_a2 = VV2_2((Pi2-1)*F*C + (Fi2-1)*C + state2a(:)); % values for party 2
      sums_b2 = VV2_2((Pi2-1)*F*C + (Fi2-1)*C + state2b(:));

      value_later_a1 = reshape(sums_a1, size(state2a));
      value_later_b1 = reshape(sums_b1, size(state2b));
      value_later_a2 = reshape(sums_a2, size(state2a));
      value_later_b2 = reshape(sums_b2, size(state2b));
      later_1 = (xprob2 .* value_later_b1 + (1 - xprob2) .* value_later_a1);
      later_2 = (xprob2 .* value_later_b2 + (1 - xprob2) .* value_later_a2);
    
      eideal = S_C(state1(:)) + dc(eactions(:, Fi)); %ideal share, economically
    
      [nrow, ncol] = size(state1);
      
      if Pi == 1
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(1), ...
                            ideals(1), reshape(eideal, size(state1)), util_type); ...
        % the current state plus the marginal share increase determines the payoff
    
        values = payoff_now + exp(-discounts(1)) * later_1;  % 101x20 matrix for actions x energy states
        [VV1_1(:, Fi, Pi), strat_1(:, Fi)] = max(values); % gives the maximum value and the argmax action
      
        choice_indexes = ((1:C)-1) * nrow + strat_1(:, Fi)';
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(2), ...
                              ideals(2), eideal(choice_indexes), util_type);

        VV1_2(:, Fi, Pi) = payoff_other + exp(-discounts(2)) * later_2(choice_indexes);
      else
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(2), ...
                            ideals(2), reshape(eideal, size(state1)), util_type);

        values = payoff_now + exp(-discounts(2)) * later_2;
        [VV1_2(:, Fi, Pi), strat_2(:, Fi)] = max(values);

        choice_indexes = ((1:C)-1) * nrow + strat_2(:, Fi)';
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(1), ...
                              ideals(1), eideal(choice_indexes), util_type);

        VV1_1(:, Fi, Pi) = payoff_other + exp(-discounts(1)) * later_1(choice_indexes);
      end
    end
  end
else % election period
  for Fi = 1:F  % indices for position of the current state in the coal price space
    Fi2 = Fi;

    dcef = dc(eactions(:, Fi));
      
    % initially, action is to do nothing
    actions_1 = ones(1, C);
    actions_2 = ones(1, C);
    % alternative, initially do prefactions
   
    %indices = find(mod([1: 5360],268)==0);
    %actions_1 = prefactions(indices,Fi,1)';
    %actions_2 = prefactions(indices,Fi,2)';
    % determine best response
    for ii = 1:stratrecurse
      [actions_1_recurse, VV1_1_rec] ...
          = electprop([Fi2], 1, VV2_1, actions_2, dcef, ...
                      state1, state2a, state2b, xprob2, q_c, Q_const, ...
                      lambdas(1), ideals(1), discounts(1), util_type, ...
                      voteModel, 0, vmArgs,D_C_min, D_C_max, C);
                 
      [actions_2_recurse, VV1_2_rec] ...
          = electprop([Fi2], 2, VV2_2, actions_1, dcef, ...
                      state1, state2a, state2b, xprob2, q_c, Q_const, ...
                      lambdas(2), ideals(2), discounts(2), util_type, ...
                      voteModel, 0, vmArgs, D_C_min, D_C_max, C);
      actions_1 = actions_1_recurse;
      actions_2 = actions_2_recurse;
    end
    for Pi=1:2    
    VV1_1(:, Fi, Pi) = VV1_1_rec;
    VV1_2(:, Fi, Pi) = VV1_2_rec;
    end
    strat_1(:, Fi) = actions_1;
    strat_2(:, Fi) = actions_2;
  end
end

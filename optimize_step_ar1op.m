function [VV1_1, VV1_2, strat_1, strat_2] = ...
    optimize_step_ar1op(VV2_1, VV2_2, N,  C, D_C_min, D_C_max, P_f_min, P_f_max, F, state1, state2a, ...
                        state2b, xprob2, dc, q_c, q_f, Q_const, lambdas, ideals, ...
                        discounts, util_type, voteModel, vmArgs, ...
                        is_election, eactions, prefactions, sigma,process)
% Perform a single timestep, with AR(1)-style retrospective opinions
%
% VV2_1 and VV2_2 are the future valuations of all states of the
%   world for parties 1 and 2
% N, C, P_f_min, P_f_max, F, and Q_const are normal run parameters
% state1, state2a, state2b, xprob2, q_c, and q_f are from make_actions
% dc is (possibly fractional) state changes from each action
% lambdas, ideals, discounts, and util_type define party preferences
% voteModel and vmArgs define the election process
% eactions are the economically optimal actions under each state
% prefactions are the parties apolitically preferred actionns
%   eactions: [C x F], prefactions: [C x F x 2]
% process defines the simustep Monte Carlo algorithm

P_f = linspace(P_f_min, P_f_max, F);
S_C = linspace(0, 1, C);

% [clean energy shares] x [fuel prices] x [incumbent] x [last year favorite?]
VV1_1 = zeros(C, F, 2, 2);
VV1_2 = zeros(C, F, 2, 2);
% [clean energy shares] x [fuel prices] x [last year favorite?]
strat_1 = zeros(C, F, 2);
strat_2 = zeros(C, F, 2);

for Pi = 1:2  % Pi stands for party, Pi=1 is the brown party and Pi=2 is the green party
  for LF = 0:1 % LF is 1 if Pi was last year's favorite
    for Fi = 1:F  % indices for position of the current state in the coal price space
      sums_a1 = zeros(size(state2a)); % values for party 1
      sums_b1 = zeros(size(state2b));
      sums_a2 = zeros(size(state2a)); % values for party 2
      sums_b2 = zeros(size(state2b));

      eideal = reshape(S_C(state1(:)) + dc(eactions(:, Fi)), size(state1)); %ideal share, economically
      s_oppos = reshape(S_C(state1(:)) + dc(prefactions(:, Fi, 3 - Pi)), size(state1));
      s_incum = S_C(state1) + q_c/Q_const;
      
      prob_current_favorite = election(voteModel, true, S_C(state1), ...
                                       s_incum, s_oppos, eideal, vmArgs(1:end-1));
      prob_favorite = vmArgs(end) * prob_current_favorite + (1 - vmArgs(end)) * LF;
      
      for ii = 1:N
        [P_f2] = simustep(P_f(Fi), process, sigma);
        Fi2 = discrete(P_f2, P_f_min, P_f_max, F);  % says in which bin of the discretized coal price space P_f2 falls

        if is_election
          % If there's an election, in prob_favorite states, both favorite and incumbent change
          sums_a1 = sums_a1 + prob_favorite .* VV2_1((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a) + ...
                    (1 - prob_favorite) .* VV2_1((0)*F*C*2 + (2-Pi)*F*C + (Fi2-1)*C + state2a);
          sums_b1 = sums_b1 + prob_favorite .* VV2_1((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b) + ...
                    (1 - prob_favorite) .* VV2_1((0)*F*C*2 + (2-Pi)*F*C + (Fi2-1)*C + state2b);
          sums_a2 = sums_a2 + prob_favorite .* VV2_2((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a) + ...
                    (1 - prob_favorite) .* VV2_2((0)*F*C*2 + (2-Pi)*F*C + (Fi2-1)*C + state2a);
          sums_b2 = sums_b2 + prob_favorite .* VV2_2((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b) + ...
                    (1 - prob_favorite) .* VV2_2((0)*F*C*2 + (2-Pi)*F*C + (Fi2-1)*C + state2b);
        else
          % If there's no election, in prob_favorite states, only favorite changes
          sums_a1 = sums_a1 + prob_favorite .* VV2_1((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a) + ...
                    (1 - prob_favorite) .* VV2_1((0)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a);
          sums_b1 = sums_b1 + prob_favorite .* VV2_1((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b) + ...
                    (1 - prob_favorite) .* VV2_1((0)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b);
          sums_a2 = sums_a2 + prob_favorite .* VV2_2((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a) + ...
                    (1 - prob_favorite) .* VV2_2((0)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2a);
          sums_b2 = sums_b2 + prob_favorite .* VV2_2((1)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b) + ...
                    (1 - prob_favorite) .* VV2_2((0)*F*C*2 + (Pi-1)*F*C + (Fi2-1)*C + state2b);
        end
      end

      value_later_a1 = reshape(sums_a1, size(state2a)) / N;
      value_later_b1 = reshape(sums_b1, size(state2b)) / N;
      value_later_a2 = reshape(sums_a2, size(state2a)) / N;
      value_later_b2 = reshape(sums_b2, size(state2b)) / N;
      later_1 = (xprob2 .* value_later_b1 + (1 - xprob2) .* value_later_a1);
      later_2 = (xprob2 .* value_later_b2 + (1 - xprob2) .* value_later_a2);
        
      [nrow, ncol] = size(state1);
      
      if Pi == 1
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(1), ...
                            ideals(1), reshape(eideal, size(state1)), util_type); ...
        % the current state plus the marginal share increase determines the payoff
      
        values = payoff_now + exp(-discounts(1)) * later_1;  % 101x20 matrix for actions x energy states
        [VV1_1(:, Fi, Pi, LF+1), strat_1(:, Fi, LF+1)] = max(values); % gives the maximum value and the argmax action
      
        choice_indexes = ((1:C)-1) * nrow + strat_1(:, Fi, LF+1)';
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(2), ...
                              ideals(2), eideal(choice_indexes), util_type);

        VV1_2(:, Fi, Pi, LF+1) = payoff_other + exp(-discounts(2)) * later_2(choice_indexes);
      else
        payoff_now = payoff(S_C(state1) + q_c/Q_const, lambdas(2), ...
                            ideals(2), reshape(eideal, size(state1)), util_type);

        values = payoff_now + exp(-discounts(2)) * later_2;
        [VV1_2(:, Fi, Pi, LF+1), strat_2(:, Fi, LF+1)] = max(values);

        choice_indexes = ((1:C)-1) * nrow + strat_2(:, Fi, LF+1)';
        payoff_other = payoff(S_C + q_c(choice_indexes)/Q_const, lambdas(1), ...
                              ideals(1), eideal(choice_indexes), util_type);

        VV1_1(:, Fi, Pi, LF+1) = payoff_other + exp(-discounts(1)) * later_1(choice_indexes);
      end
    end
  end
end

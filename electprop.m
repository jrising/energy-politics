function [actions, VV1] = electprop(Fi2s, Pi, VV2, other_actions, dcef, ...
                                    state1, state2a, state2b, xprob2, q_c, Q_const, ...
                                    lambda, ideal, discount, util_type, voteModel, ...
                                    inPower, voteArgs, D_C_min, D_C_max, C)
                           

% Determines a party's optimal proposed action for an election,
% given the action of the other party, and state of world
%   other_actions is row index for each C state
% Fi2s is collection of Monte Carlo realizations for future fossil prices
% Pi is the party currently in power (1 or 2)
% VV2 is the future valuation of the given party for states of the world
% other_actions is the actions of the other party under all states
%   of the world
% dcef is the economically-optimal change in clean energy share for
%   each possible action and state of the world
% state1, state2a, state2b, xprob2, and q_c are from make_actions
% Q_const is the total energy produced (in MW)
% lambda, ideal, discount, and util_type define the given party's
%   preferences
% voteModel is the probability model used by election
% inPower is 1 if the given party is in power (0 otherwise)
% vmArgs are the parameters that go into the election model

[A, C] = size(state2a); % (action)xC (state of world)
[C, F, P] = size(VV2);
S_C = linspace(0, 1, C);
N = length(Fi2s);

% ideal share, economically
s_e = reshape(S_C(state1(:)) + dcef(:)', [A C]);  % 101 x 20 matrix giving ideal action in dc for each state of the world

% Values assuming other wins
sums_lose_a = zeros(1, C);
sums_lose_b = zeros(1, C);
lose_indexes = ((1:C)-1) * A + other_actions;  % takes index at increments of 101+1, which picks up the combinations of other-action and states  
state2_lose_a = state2a(lose_indexes);  % gets states corresponding to other_action, for each state of the world
state2_lose_b = state2b(lose_indexes);

% Values assuming I win:
sums_win_a = zeros(A, C);
sums_win_b = zeros(A, C);

for Fi2 = Fi2s
  % If I win, I act (including in next three periods when there will be no election)
  sums_win_a = sums_win_a(:) + VV2((Pi-1)*F*C + (Fi2-1)*C + state2a(:)); % first term skips to where the in-power values are
  sums_win_b = sums_win_b(:) + VV2((Pi-1)*F*C + (Fi2-1)*C + state2b(:)); 
  
  % If other wins
  sums_lose_a = sums_lose_a + VV2((2 - Pi)*F*C + (Fi2-1)*C + state2_lose_a); % first term skips to where not-in-power values are
  sums_lose_b = sums_lose_b + VV2((2 - Pi)*F*C + (Fi2-1)*C + state2_lose_b);
end

% Possible payoffs if I win

% these are all 101 x 20 matrices

later_win_a = reshape(sums_win_a, [A C]) / N;
later_win_b = reshape(sums_win_b, [A C]) / N;
later_win = (xprob2 .* later_win_b + (1 - xprob2) .* later_win_a);

s_win = S_C(state1) + q_c/Q_const;
now_win = payoff(s_win, lambda, ideal, s_e, util_type);

payoff_win = now_win + exp(-discount) * later_win; % (action)xC

% Payoffs if I lose

later_lose_a = sums_lose_a / N;
later_lose_b = sums_lose_b / N;
later_lose = (xprob2(lose_indexes) .* later_lose_b + ...
              (1 - xprob2(lose_indexes)) .* later_lose_a);

s_lose = S_C + q_c(lose_indexes)/Q_const;  % why don't we also use xprob2(lose_indexes) here?
now_lose = payoff(s_lose, lambda, ideal, s_e(lose_indexes), util_type);

payoff_lose = now_lose + exp(-discount) * later_lose;

% Preference of voters

prob_win = election(voteModel, inPower, s_win, repmat(s_lose, A, 1), ...
                    s_e, voteArgs, D_C_min, D_C_max, C);

payoffs = prob_win .* payoff_win + (1 - prob_win) .* repmat(payoff_lose, A, 1);

[VV1, actions] = max(payoffs);
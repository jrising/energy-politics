function [state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const)
% All returned matrices have a row for each action (1-...)
%   and a column for each current state of the world (C)
% state1 is the state before actions take effect
% state2a and state2b are two possible states that could result
%   from the given action, with state b with proabability xprob2

D_C = linspace(D_C_min, D_C_max, D);

state1 = repmat(1:C, 1+D, 1); % as indices

state2a = [1:C]; % as indices
state2b = [1:C]; % as indices
prob2 = [1]; % prob of going to state2b
for ii = 1:sum(D_C < 0)
  state2a = [state2a; (1:C) + ceil(D_C(ii))];
  state2b = [state2b; (1:C) + floor(D_C(ii))];
  prob2 = [prob2 1 - (-floor(D_C(ii)) + D_C(ii))]; % The probability increases linearly with the magnitude of the action 
end
for ii = 1:sum(D_C >= 0)
  state2a = [state2a; (1:C) + floor(D_C(ii + sum(D_C < 0)))];
  state2b = [state2b; (1:C) + ceil(D_C(ii + sum(D_C < 0)))];
  prob2 = [prob2 1 - (ceil(D_C(ii + sum(D_C < 0))) - D_C(ii + sum(D_C < 0)))];
end
state2a(state2a < 1) = 1;
state2a(state2a > C) = C;
state2b(state2b < 1) = 1;
state2b(state2b > C) = C;
xprob2 = repmat(prob2', 1, C);

q_c = Q_const * repmat([0 D_C/C]', 1, C);
q_f = -q_c;


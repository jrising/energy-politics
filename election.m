function prob_win = election(voteModel, inPower, s_current, s_self, s_other, ...
                             s_e, args)
                         
                      
% Calculates the probability of the given party being in power after an
% election
% voteModel is one of the following:
%  - 0: the party in power never changes
%  - 1: the party will win
%  - 2: the party will lose
%  - 3: the party to win is the party not currently in power
%  - 4: the party has args(1) probability of winning
%  - 5: "High elasticity model"
%  - 6: "Low elasticity model"
%  - 7: "Linear model"
% inPower is 1 if the given party is currently in power
% s_self and s_other are matrices for different
%   combinations of states of world and actions, representing the
%   proposed share of clean energy

switch voteModel
 case 0
  prob_win = repmat(inPower, size(s_self));
 case 1
  prob_win = repmat(1, size(s_self));
 case 2
  prob_win = repmat(0, size(s_self));
 case 3
  prob_win = repmat(1 - inPower, size(s_self));
 case 4
  prob_win = repmat(args(1), size(s_self)); % probability value
 case {5, 6, 7}
  lambda = args(1);
  if lambda ==-1
      lambda = s_current*.3 ;
  end
  s_voters = lambda + (1 - lambda) .* s_e;

  delta = abs(s_voters - s_other) - abs(s_voters - s_self);
  
  b = args(2);
  a = exp(.5 / b) - 1;
  prob_win = .5 * ones(size(delta));
  inter = 1;
  if voteModel == 5
    prob_win(delta >= 0) = .5 + b*log(a*delta(delta >= 0)/inter + 1);
    prob_win(delta < 0) = .5*delta(delta < 0)/inter - (b*log(a*(1 - abs(delta(delta < 0)/inter+1)) + 1) - .5*(1-delta(delta < 0)/inter));
  elseif voteModel == 6
    prob_win(delta >= 0) = .5 + .5*delta(delta >= 0)/inter - (b*log(a*(1-delta(delta >= 0)/inter) + 1) - .5*(1-delta(delta >= 0)/inter));
    prob_win(delta < 0) = b*log(a * abs(delta(delta < 0)/inter + 1) + 1);
  else
    prob_win = .5 + delta/2;
  end
 otherwise
  error('Unknown voting model in election')
end
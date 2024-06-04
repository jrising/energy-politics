function [value] = simuvote(Q, mcs, q_c_party1, q_f_party1, ...
                            q_c_party2, q_f_party2)
% mcs is the minimum cost (economical) share of clean energy
lambda_e = randbeta(2, 5);

q_c = Q * (lambda_e + (1 - lambda_e) * mcs);
q_f = Q - q_c;

value1 = -(q_c_party1 - q_c).^2 - (q_f_party1 - q_f).^2;
value2 = -(q_c_party2 - q_c).^2 - (q_f_party2 - q_f).^2;

if value1 > value2
  return 1
else
  return 2
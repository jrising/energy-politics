function [P_f2] = simustep(P_f1, process, sigma)
dt = 1; % Time step

if process == 1
  %%% Fuss 2008 Process
  
  % Market uncertainty
  sigma_f = 0.0092376; % Electricity volatility parameter

  % Price drives
  mu_f = log(3860); % Price of electricity reverts to mean exp(mu_f)
  alpha = 0.045564;

  dW_f = randn(1) * dt;
  dP_f = alpha * (mu_f - log(P_f1)) * P_f1 * dt + sigma_f * P_f1 * dW_f;
  
  P_f2 = max(0, P_f1 + dP_f);
elseif process == 2
  %%% AR(1) Process
  
  % Market uncertainty
  %sigma = 0.08; % Coal price volatility parameter

  % Price drives
  mu = .03; % Price of electricity reverts to mean exp(mu_f) - parameter in Trancik paper is 0.144 - not the same as fit found in coaldata.m
  %gamma = 0.956;  % within statistical error, gamma = 1, which gives a random walk

  dW_f = normrnd(0,sigma);
  %log_P_f = log(P_f1) + dW_f; % pure random walk
  log_P_f= log(P_f1) + mu + dW_f ; % AR(1) process

  P_f2 = exp(log_P_f);
else
  error('Unknown process number');
end

% 1 MW = 31.5576 TJ/year
% 1e6 J/s * 60*60*24 s/day * 365.25 day/year * 1/1e12 TJ/J

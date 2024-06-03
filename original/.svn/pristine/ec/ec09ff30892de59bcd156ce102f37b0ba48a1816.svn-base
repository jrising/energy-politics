function [P_e2, P_c2] = simustep(P_e1, P_c1)
% Values like [A B] are without CCS, with CCS.

dt = 1; % Time step
rho = .7; % Correlation between CO2 price changes and electricity
          % price

% Market uncertainty
sigma_c = 0.0287; % CO2 volatility parameter
sigma_e = 0.092376; % Electricity volatility parameter

% Price drives
mu_c = 0.0568; % Price drift for CO2 ($/ton of CO2)
mu_e = log(37); % Price of electricity reverts to mean exp(mu_e)
alpha = 0.45564;

rho_coeff = sqrt(1 / (1 / rho - 1)); % Calculated in Env. Data., HW3

dW_c = randn(1) * dt;
dW_e = rho_coeff * dW_c + randn(1) * dt;
dP_e = alpha * (mu_e - log(P_e1)) * P_e1 * dt + sigma_e * P_e1 * dW_e;
dP_c = mu_c * P_c1 * dt + sigma_c * P_c1 * dW_c;

P_e2 = max(0, P_e1 + dP_e);
P_c2 = max(0, P_c1 + dP_c);

% 1 MW = 31.5576 TJ/year
% 1e6 J/s * 60*60*24 s/day * 365.25 day/year * 1/1e12 TJ/J

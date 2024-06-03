function yy = profit(mm, P_e, P_c, ca)

% Constant prices
P_f = 1876; % Fuel cost ($/TJ)
P_h = 11347; % Heat price ($/TJ)
OC = [57375000 70581522]; % O&M fixed cost ($/year)

% Quantities
q_e = [36188 29107]; % Electricity output (TJ/year)
q_h = .34 * 31.5576 * [1530 1231]; % heat production (estimated)
q_c = [7442050 1079097]; % CO2 emissions (tCO2/year)
q_f = [78669 78669]; % Fuel consumption (TJ/year)

yy = q_e(mm) * P_e * 277.78 + q_h(mm) * P_h - q_c(mm) * P_c - ...
     q_f(mm) * P_f - OC(mm) - ca;

% Price of electricity in $/MW h
% 1 TJ = 277.78 MW h
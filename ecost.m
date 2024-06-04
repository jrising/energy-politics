function yy = ecost(s_c, Q, q_c, q_f, P_f, alpha_wind, alpha_solar, declining, e_of_scale)
% Q, q_c, and q_f are in MW
%   s_c may be vector, q_c and q_f as scalars OR
%   s_c, q_c, and q_f may be all matrices of the same dimensions
% P_f is in $/TJ = $/(TW s) * 1 TW / 1e6 MW * 1e6 s / Ms = ($/Ms)/MW
Msecs = 365.25*24*60*60/1e6;
% Msecs is the number of seconds to calculate over / 1e6
%   (31.558 for a year)

% Fossil Fuel Technologies

FC_f = P_f * Msecs * (1 - s_c) * Q;

% Constant prices
OC_f_q = 36e3; % O&M fixed cost ($/year/MW)
OC_f = ((1 - s_c) * Q) * OC_f_q;

% Construction costs at $2000 / kW
CC_f = 2000 * 1000 * q_f;
CC_f(q_f < 0) = 0;

% Clean Technologies
OC_wind = 22e3;
OC_solar = 28e3;

%alpha_wind = .35;
%alpha_solar = .2;

if e_of_scale
  cost_scale = s_c * Q;
else
  cost_scale = .1 * Q;
end

OC_c = ((OC_wind + OC_solar) / 2) * s_c * Q;
if declining == 0
  [rows, cols] = size(s_c);
  CC_wind_q = zeros(rows, cols);
  CC_solar_q = zeros(rows, cols);
  
  CC_wind_q(s_c > 0) = (4750 / (6400^-alpha_wind)) * (s_c(s_c > 0) * Q).^-alpha_wind;
  CC_solar_q(s_c > 0) = (2400 / (52e3^-alpha_solar)) * (s_c(s_c > 0) * Q).^-alpha_solar;
  CC_c = ((CC_wind_q + CC_solar_q) / 2) .* 1000 .* q_c .* ...
         exp(34*q_c ./ cost_scale);
else 
  [rows, cols] = size(s_c);
  CC_wind_q = zeros(rows, cols);
  alpha_wind_adj = zeros(rows,cols);
  alpha_solar_adj = zeros(rows,cols);
  CC_wind0 = zeros(rows, cols);
  CC_solar0 = zeros(rows, cols);
  alpha_wind_adj(s_c>0) = alpha_wind*(s_c(s_c > 0) * Q < 600e3)+ alpha_wind/2*(s_c(s_c > 0) * Q >= 600e3); 
  alpha_solar_adj(s_c>0) = alpha_solar*(s_c(s_c > 0) * Q < 600e3)+ alpha_solar/2*(s_c(s_c > 0) * Q >= 600e3); 
  CC_wind0(s_c>0) = (2400/(60e3^-alpha_wind)) * (s_c(s_c > 0) * Q < 600e3) + (2400/(60e3^-alpha_wind) * (600e3^-(alpha_wind/2))*(s_c(s_c > 0) * Q >= 600e3));
  CC_wind_q(s_c > 0) = CC_wind0(s_c>0) .* (s_c(s_c > 0) * Q).^-alpha_wind_adj(s_c>0);
  CC_c = CC_wind_q .* 1000 .* q_c .* exp(34*q_c ./ cost_scale);
end    
    
% For s_c == 0, treat like s_c * Q == 1
% CC_wind_q(s_c == 0) = 1.0206e+05;
% CC_solar_q(s_c == 0) = 2.1058e+04;
CC_c(s_c == 0) = ((1.0206e+05 + 2.1058e+04) / 2) .* 1000 .* ...
          q_c(s_c == 0) .* exp(q_c(s_c == 0)./(.1*Q));
CC_c(q_c < 0) = 0;

% Combined cost

yy = FC_f + OC_f + OC_c + CC_f + CC_c;
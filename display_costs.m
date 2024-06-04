addpath('../lib');

% Determine the optimal cost path
Q_const = 2281591; % MW: 1e6 * (20000 TWh / year) / (8766 hr / year)
C = 20; % Number of clean energy shares for planning
D_C_min = -.5; % Highest clean energy decrease
D_C_max = 1; % Highest clean energy increase
D = 100;
P_f_min = 1000;
P_f_max = 6000;
F = 10;
alpha_wind = .35;
alpha_solar = .2;
fuel_sigma = 0.08;
estrat = optimize_cost(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                       F, Q_const, alpha_wind, alpha_solar, 2, 0, ...
                       fuel_sigma, 1);

D_C = [0 linspace(D_C_min, D_C_max, D)/C];
colors = bwcolor(F);
P_f = linspace(P_f_min, P_f_max, F);

% BASELINE 0: Cost of economically optimal actions

do_plot = 2;

clf
for Fi = 1:F
  cc = .143;
  costs_estrat = [];
  costs_zeroact = [];
  costs_const = [];
  for ii = 2:50
    before = discrete(cc, 0, 1, C);
    costs_estrat(ii-1) = ecost(cc, Q_const, estrat(ii-1, before, Fi), -estrat(ii-1, before, Fi), P_f(Fi), alpha_wind, alpha_solar, 0, 1);
    costs_zeroact(ii-1) = ecost(cc, Q_const, 0, 0, P_f(Fi), alpha_wind, alpha_solar, 0, 1);
    costs_const(ii-1) = ecost(.143, Q_const, 0, 0, P_f(Fi), alpha_wind, alpha_solar, 0, 1);
    
    ac = estrat(ii-1, before, Fi);
    cc = cc + D_C(ac);
  end
  
  switch do_plot
   case 0
    plot(2013:2061, costs_estrat, '-', 'Color', colors(Fi, :));
    plot(2013:2061, costs_zeroact, ':', 'Color', colors(Fi, :));
   case 1
    plot(2013:2061, costs_zeroact ./ costs_estrat, '-', 'Color', colors(Fi, :));
   case 2
    plot(2013:2061, costs_const ./ costs_estrat, '-', 'Color', colors(Fi, :));
  end
  
  hold on
end
switch do_plot
 case 0
  title('Cost of Economically-Optimal Actions', ...
        'fontsize', 20);
  ylabel('Action Cost ($)')
 case 1
  title('Cost of not investing in each year', ...
        'fontsize', 20);
  ylabel('Ratio of action costs')
 case 2
  title('Cost of never investing compared to optimal', ...
        'fontsize', 20);
  ylabel('Ratio of yearly costs')
end

xlabel('Year');

switch do_plot
 case 0
  axis([2013 2061 0 5e11])
 case 1
  axis([2013 2061 .9996 1])
 case 2
  axis([2013 2061 .9 1.6])
end

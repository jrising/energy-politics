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
estrat = optimize_cost(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                       F, Q_const, alpha_wind, alpha_solar, 2, 1);

% Determine preferred strategies
lambdas = [.05 .05];
prefstrats = preferred_strategies(50, C, D_C_min, D_C_max, D, F, ...
                                  Q_const, lambdas, [0 1], 1, estrat);

prefstrats_eideal = prefstrats;
prefstrats_eideal(:, :, :, 1) = estrat;
prefstrats_eideal(:, :, :, 2) = estrat;

S_C = linspace(0, 1, C);
D_C = [0 linspace(D_C_min, D_C_max, D)/C];

voteModel = 5;
vmArgs = [.1 .5];

[strat1, strat2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                    Q_const, lambdas, [0 1], [.05 .05], 1, 4, 'retex', ...
                                    voteModel, vmArgs, estrat, prefstrats_eideal, 2);

clf
hold on
plot(S_C, D_C(estrat(4, :, 5)), 'y-')
plot(S_C, D_C(strat1(4, :, 5)), 'k-')
plot(S_C, D_C(strat2(4, :, 5)), 'g-')

vmArgs = [-1 .5];

[strat1, strat2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                    Q_const, lambdas, [0 1], [.05 .05], 1, 4, 'retex', ...
                                    voteModel, vmArgs, estrat, prefstrats_eideal, 2);
plot(S_C, D_C(strat1(4, :, 5)), 'k.')
plot(S_C, D_C(strat2(4, :, 5)), 'g.')

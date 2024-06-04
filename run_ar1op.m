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


% Experiment 1: Compare MC elections and expected values

% Run MC elections twice
[strat1_retro0a, strat2_retro0a] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retro', ...
                                                  voteModel, vmArgs, estrat, prefstrats_eideal, 2);
[strat1_retro0b, strat2_retro0b] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retro', ...
                                                  voteModel, vmArgs, estrat, prefstrats_eideal, 2);

% Run expected value elections twice
[strat1_retro1a, strat2_retro1a] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retex', ...
                                                  voteModel, vmArgs, estrat, prefstrats_eideal, 2);
[strat1_retro1b, strat2_retro1b] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retex', ...
                                                  voteModel, vmArgs, estrat, prefstrats_eideal, 2);

clf
hold on
plot(S_C, D_C(estrat(4, :, 5)), 'y-')
plot(S_C, D_C(strat1_retro0a(4, :, 5)), 'k-')
plot(S_C, D_C(strat2_retro0a(4, :, 5)), 'g-')
plot(S_C, D_C(strat1_retro0b(4, :, 5)), 'k:')
plot(S_C, D_C(strat2_retro0b(4, :, 5)), 'g:')
plot(S_C, D_C(strat1_retro1a(4, :, 5)), 'r-')
plot(S_C, D_C(strat2_retro1a(4, :, 5)), 'b-')
plot(S_C, D_C(strat1_retro1b(4, :, 5)), 'r:')
plot(S_C, D_C(strat2_retro1b(4, :, 5)), 'b:')
legend('Economically Optimal', 'Brown, Monte Carlo 1', ...
       'Green, Monte Carlo 1', 'Brown, Monte Carlo 2', ...
       'Green, Monte Carlo 2', 'Brown, Expected Val 1', ...
       'Green, Expected Val 1', 'Brown, Expected Val 2', ...
       'Green, Expected Val 2', 'Location', 'SouthWest')

% Experiment 2: Compare assumptions for retro opposition party

% With election-year-only opinions
[strat1_retro, strat2_retro] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retex', ...
                                                  voteModel, vmArgs, estrat, prefstrats, 2);

clf
hold on
plot(S_C, D_C(estrat(4, :, 5)), 'y-')
plot(S_C, D_C(strat1_retro1a(4, :, 5)), 'r-')
plot(S_C, D_C(strat2_retro1a(4, :, 5)), 'b-')
plot(S_C, D_C(strat1_retro(4, :, 5)), 'r:')
plot(S_C, D_C(strat2_retro(4, :, 5)), 'b:')
legend('Economically Optimal', 'Brown, assuming EO opp', ...
       'Green, assuming EO opp', 'Brown, assuming apol opp', ...
       'Green, assuming apol opp', 'Location', 'SouthWest')

% Experiment 2: Compare retro to AR(1) elections

% With AR(1)-style opinions
vmArgs = [.1 .5];

[strat_1, strat_2, VV2_1, VV2_2] = optimize_nolimit_ar1op(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.05 .05], [0 1], [.05 .05], 1, ...
                                                  4, voteModel, [vmArgs .5], estrat, prefstrats, 2);

clf
plot_strat(estrat, C, D_C_min, D_C_max, D, 'y-');
plot_strat(strat1_retro, C, D_C_min, D_C_max, D, 'r-');
plot_strat(strat2_retro, C, D_C_min, D_C_max, D, 'b-');

P_fs = linspace(P_f_min, P_f_max, F);
s_c1 = simustrat_ar1op(50, C, D_C_min, D_C_max, D, strat_1, prefstrats(:, :, :, 2), estrat, ...
                       P_f_min, P_f_max, F, ones(1, 50)*P_fs(5), ...
                       .143, voteModel, [vmArgs .5]);
plot(2013:2062, s_c1, 'r.')
s_c2 = simustrat_ar1op(50, C, D_C_min, D_C_max, D, strat_2, prefstrats(:, :, :, 1), estrat, ...
                       P_f_min, P_f_max, F, ones(1, 50)*P_fs(5), ...
                       .143, voteModel, [vmArgs .5]);
plot(2013:2062, s_c2, 'b.')
legend('Economically Optimal', 'Brown, assuming apol opp', ...
       'Green, assuming apol opp', 'Brown, AR(1) opinions', ...
       'Green, AR(1) opinions', 'Location', 'NorthWest')

clf
hold on
plot(S_C, D_C(estrat(4, :, 5)), 'y-')
plot(S_C, D_C(strat1_retro(4, :, 5)), 'r-')
plot(S_C, D_C(strat2_retro(4, :, 5)), 'b-')
plot(S_C, D_C(strat1_retro(3, :, 5)), 'r:')
plot(S_C, D_C(strat2_retro(3, :, 5)), 'b:')
plot(S_C, D_C(strat_1(4, :, 5, 1)), 'k-')
plot(S_C, D_C(strat_2(4, :, 5, 1)), 'g-')
plot(S_C, D_C(strat_1(3, :, 5, 1)), 'k:')
plot(S_C, D_C(strat_2(3, :, 5, 1)), 'g:')
legend('Economically Optimal', 'Brown, retro, election', ...
       'Green, retro, election', 'Brown, retro, off-year', ...
       'Green, retro, off-year', 'Brown, AR(1), election', ...
       'Green, AR(1), election', 'Brown, AR(1), off-year', ...
       'Green, AR(1), off-year', 'Location', 'SouthWest')

% Experiment 3: Try cognitive hierarchy
S_C = linspace(0, 1, C);
D_C = [0 linspace(D_C_min, D_C_max, D)/C];

[strat1_retex, strat2_retex] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.04 .04], [0 1], [.05 .05], 1, 4, 'retex', ...
                                                  voteModel, vmArgs, estrat, prefstrats, 2);

[strat1_coghi, strat2_coghi] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                Q_const, [.04 .04], [0 1], [.05 .05], 1, 4, 'coghi', ...
                                                voteModel, vmArgs, estrat, nan, 2);
clf
hold on
plot(S_C, D_C(estrat(4, :, 5)), 'y-')
plot(S_C, D_C(strat1_retex(4, :, 5)), 'b-')
plot(S_C, D_C(strat2_retex(4, :, 5)), 'b-')
plot(S_C, D_C(strat1_coghi(4, :, 5)), 'r-')
plot(S_C, D_C(strat2_coghi(4, :, 5)), 'r-')

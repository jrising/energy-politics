function [strat_1, strat_2]=compute_coghi(~)
    Q_const = 2281591; % 20000 TWh / year
    C = 20; % Number of clean energy shares for planning
    D_C_min = -2; % Highest clean energy decrease
    D_C_max = 2; % Highest clean energy increase
    D = 267;
    F = 10;
    P_f_min = 1000;
    P_f_max = 6000;
    P_f0 = 3860;
    s_c0 = .143;
    N = 50;
    termlen = 4;
    ideals = [0, 1];
    sigma = 0.08;
    e_of_scale = 1;
    declining = 1; % 0 if no declining learning rates, 1 if learning rates are declining.
    util_type = 1;

    % Parameters of interest as IVs: re-election probability, learning
    % coefficient, lambdas
    M = 100;
    M_sim = 100; % to distinguish the # of iterations in our simulations (versus the # of iterations of players' mental simulations)
    S = 100; % horizon for economically optimal
    S2 = 50;
    alpha_wind = .35;
    alpha_solar = .2;   
    process = 2;
    discounts = [.05, .05];
    S_C = linspace(0, 1, C);
    D_C = [0 linspace(D_C_min, D_C_max, D)/C];
    estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                            F, Q_const, alpha_wind, alpha_solar, process, declining, sigma, e_of_scale);

    voteModel = 5;
    b = .5';
    lambda_p = [.01 .04 .06];
    lambda_e = 0:0.05:.5;
    scen = cartprod( lambda_e, lambda_p, lambda_p);

    strat_1 = zeros(49, C, F, length(scen));
    strat_2 = zeros(49, C, F, length(scen));

for ii=1:length(scen)
    vmArgs = [scen(ii,1) b];
    lambdas = [scen(ii,2) scen(ii,3)];
    prefstrats = preferred_strategies(50, C, D_C_min, D_C_max, D, F, ...
                                  Q_const, lambdas, [0 1], 1, estrat);
    prefstrats_eideal = prefstrats;
    prefstrats_eideal(:, :, :, 1) = estrat(1:49,:,:);
    prefstrats_eideal(:, :, :, 2) = estrat(1:49,:,:);
    [strat_1(:,:,:,ii), strat_2(:,:,:,ii), VV2_1, VV2_2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, lambdas, [0 1], [.05 .05], 1, 4, 'coghi', ...
                                                  voteModel, vmArgs, estrat, prefstrats, sigma, 2);
end
strat_1_coghi = strat_1;
strat_2_coghi = strat_2;
savefile = 'coghi_bhigher.mat'
save(savefile,'strat_1_coghi','strat_2_coghi')
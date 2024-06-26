% parameters of little interest as IVs (kept constant across simulations,
% except for checking robustness)

Q_const = 2281591; % 20000 TWh / year
C = 20; % Number of clean energy shares for planning
D_C_min = -.5; % Highest clean energy decrease
D_C_max = 1; % Highest clean energy increase
D = 100;
F=10;
P_f_min = 1000;
P_f_max = 6000;
P_f0 = 3860;
s_c0 = .143;
N = 50;
termlen = 4;
ideals = [0, 1];

% Parameters of interest as IVs: re-election probability, learning
% coefficient, lambdas
M = 100;
M_sim = 500; % to distinguish the # of iterations in our simulations (versus the # of iterations of players' mental simulations)
S = 50;
alpha_wind = .35;
alpha_solar = .2; 
lambdas = [.01, .01];  
p_b = .5; 
process = 2;
discounts = [.05, .05];
util_type = 1;

% Generating strategies
[estrat, strat1, strat2] = run_fun(N, S, C, D_C_min, D_C_max, D, ...
                                 P_f_min, P_f_max, F, Q_const, ...
                                 alpha_wind, alpha_solar, lambdas, ...
                                 ideals, termlen, p_b);
                             

D_C = [0 linspace(D_C_min, D_C_max, D)/C];
year=1;

figure(1)
strat1_year=reshape(strat1(year,:,:), 20, 10);
surf(D_C(strat1_year))   
ylabel('Clean energy shares')
xlabel('Coal price')
title(sprintf('Brown party strategy, in year %d with brown election prob=%6.1f and lambda=%6.2f', year, p_b , lambdas(1)))

figure(2)
strat2_year=reshape(strat2(year,:,:), 20, 10);
surf(D_C(strat2_year))
ylabel('Clean energy shares')
xlabel('Coal price')
title(sprintf('Green party strategy, in year %d with brown election prob=%6.1f  and lambda=%6.2f', year, p_b , lambdas(1)))

figure(3)
estrat_year=reshape(estrat(year,:,:), 20, 10);
surf(D_C(estrat_year))
ylabel('Clean energy shares')
xlabel('Coal price')
title(sprintf('Economically optimal strategy, in year %d', year ))

% Simulating paths generated by a given set of strategies (marion original
% wrong method)
paths = zeros(S, M_sim, 2);
for ii=1:M_sim
  P_f = simu(S, P_f0, 2);
  inpower = repmat((1 + binornd(1,1-p_b, 1,13)), 4, 1); 
  inpower = [0 inpower(1:49)];
  paths(:,ii,1) = simpath(strat1, strat2, inpower, P_f, P_f_min, P_f_max, F, C, D_C_min, D_C_max, D);
  paths(:,ii,2) = inpower;
end


plot(2013:2062, paths(:,:,1))


% Clean energy share in 2030 and 2050 as a function of brown party's probability of winning 
p_b=linspace(0,1,21);
alpha_wind = .35;
alpha_solar = .2;
output_p = zeros(size(p_b,2), 4, 4);
paths_p = zeros(size(p_b,2), S, M_sim); % in case we want to examine the 
%trajectories instead of merely the aggregate output variables

estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process);
for ii=1:size(p_b,2)
    [stratb, stratg] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, lambdas, ideals, discounts, util_type, ...
                              termlen , p_b(ii), estrat, process);

    [output_p(ii,:,:), paths_p(ii, :, :) ] = run_sim(S, M_sim, P_f0 , 2, 50, C, D_C_min, D_C_max, D, ...
    stratb, stratg, P_f_min, P_f_max, F, P_f, .143, 0, 1 , p_b(ii));
    
end

%plotting
xlabels = 'Probability of election';
ylabel_1 = 'Clean energy share';
ylabel_2 = 'Annual change in clean energy by said party';
output = output_p;
param = p_b;
% plot(2013:2062, reshape(paths_p(10,:,:), S, M_sim))
% The only thing to change below are the titles and file output names 
h1 = figure(1);
plot_output(output,param, 1, xlabels, ylabel_1)
title(sprintf('Clean energy share in 2030 vs. the brown party''s prob. of winning with lambda=%6.2f', lambdas(1)))

h2 = figure(2);
plot_output(output,param, 2, xlabels, ylabel_1)
title(sprintf('Clean energy share in 2050 vs. the brown party''s prob of winning  with lambda=%6.2f', lambdas(1)))

h3 = figure(3);
plot_output(output,param, 3, xlabels, ylabel_2)
title(sprintf('Annual change in clean energy by green party vs. the brown party''s prob. of winning with lambda=%6.2f', lambdas(1)))


h4 = figure(4);
plot_output(output,param, 4, xlabels, ylabel_2)
title(sprintf('Annual change in clean energy by brown party vs. the brown party''s prob. of winning with lambda=%6.2f', lambdas(1)))

% change lambda if needed
print(h1, '-dpng','results/comp_stats/Share30_v_p2_l02.pgn')
print(h2, '-dpng','results/comp_stats/Share50_v_p2_l02.pgn')
print(h3, '-dpng','results/comp_stats/GrActions_v_p2_l02.pgn')
print(h4, '-dpng','results/comp_stats/BrActions_v_p2_l02.pgn')



%saving data % May have to change the lambda value in the label
savefile = 'sim_pb_l02.mat';
save(savefile, 'output_p', 'paths_p');


% Clean energy share in 2030 and 2050 and party investments as a function of learning
% coefficients
p_b = .5;
alpha_wind = .35;
alpha_solar = linspace(.2*.5, .2*1.5, 20);
output_solar = zeros(size(alpha_solar,2), 4, 4);
paths_solar = zeros(size(alpha_solar,2), S, M_sim); % in case we want to examine the 
%trajectories instead of merely the aggregate output variables
for ii=1:size(alpha_solar,2)
    estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar(ii), process);
    [stratb, stratg] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, lambdas, ideals, discounts, util_type, ...
                              termlen , p_b, estrat, process);

    [output_solar(ii,:,:) , paths_solar(ii, :, :)] = run_sim(S, M_sim, ...
    P_f0 , 2, 50, C, D_C_min, D_C_max, D, ...
    stratb, stratg, P_f_min, P_f_max, F, P_f, .143, 0, 1 , p_b);
    
end

%plotting
param=alpha_solar;
tech='solar';
xlabels=sprintf('Technological learning parameter for %s with lambda=%6.2', tech, lambda);
ylabel_1='Clean energy share';
ylabel_2='Annual change in clean energy by brown party';
output = output_solar;

% The only thing to change below are the titles and file output names 
figure(1);
plot_output(output, param, 1, xlabels, ylabel_1)
title('Clean energy share in 2030 vs. technological learning parameters')


figure(2);
plot_output(output, param, 2, xlabels, ylabel_1)
title('Clean energy share in 2050 vs. technological learning parameters')


figure(3);
plot_output(output, param, 3, xlabels, ylabel_2)
title('Annual change in clean energy by green party vs. technological learning parameters')


figure(4);
plot_output(output, param, 4, xlabels, ylabel_2)
title('Annual change in clean energy by brown party vs. technological learning parameters')

print('-dpng','results/comp_stats/Share30_v_learn.pgn')
print('-dpng','results/comp_stats/Share50_v_learn.pgn')
print('-dpng','results/comp_stats/GrActions_v_learn.pgn')
print('-dpng','results/comp_stats/BrAtions_v_learn.pgn')
%saving data
savefile = 'sim_solar_l02.mat';
save(savefile, 'output_solar', 'paths_solar');

% Clean energy share in 2030 and 2050 and party investments as a function
% of lambda
p_b = .5;
alpha_wind = .35;
alpha_solar = .2;
lambda = linspace(0, .5, 20);
output_lambda = zeros(size(lambda,2), 4, 4);
paths_lambda = zeros(size(lambda,2), S, M_sim); % in case we want to examine the 
%trajectories instead of merely the aggregate output variables
estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process);
for ii=1:size(lambda,2)
    [stratb, stratg] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, [lambda(ii), lambda(ii)], ideals, ...
                          discounts, util_type, termlen , p_b, estrat, process);

    [output_lambda(ii,:,:), paths_lambda(ii, :, :) ] = run_sim(S, M_sim, P_f0 ,2 , 50, C, D_C_min, D_C_max, D, ...
    stratb, stratg, P_f_min, P_f_max, F, P_f, .143, 0, 1 , p_b);
    
end


% plotting
xlabels = 'Weighting of energy preference';
ylabel_1 = 'Clean energy share';
ylabel_2 = 'Annual change in clean energy by said party';
output = output_lambda;
param = lambda;


% The only thing to change below are the titles and file output names 
figure(1);
plot_output(output,param, 1, xlabels, ylabel_1)
title('Clean energy share in 2030 vs. technological learning parameters')


figure(2);
plot_output(output,param, 2, xlabels, ylabel_1)
title('Clean energy share in 2050 vs. technological learning parameters')

figure(3);
plot_output(output,param, 3, xlabels, ylabel_2)
title('Annual change in clean energy by green party vs. technological learning parameters')

figure(4);
plot_output(output,param, 4, xlabels, ylabel_2)
title('Annual change in clean energy by brown party vs. technological learning parameters')


print('-dpng','results/comp_stats/Share30_v_lambda.pgn')
print('-dpng','results/comp_stats/Share50_v_lambda.pgn')
print('-dpng','results/comp_stats/GrActions_v_lambda.pgn')
print('-dpng','results/comp_stats/BrActions_v_lambda.pgn')



% saving
savefile = 'sim_lambda.mat';
save(savefile, 'output_lambda', 'paths_lambda');

% Variation in price process
p_b = .5;
process = [1,2];
output_price = zeros(size(process,2), 4, 4);
paths_price = zeros(size(process,2), S, M_sim); % in case we want to examine the 
%trajectories instead of merely the aggregate output variables
for ii=1:size(process,2)
    estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process(ii));
    [stratb, stratg] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, lambdas, ideals,  util_type, ...
                              termlen , p_b, estrat, process(ii));

    [output_price(ii,:,:) , paths_price(ii, :, :)] = run_sim(S, M_sim, ...
    P_f0 , process(ii), 50, C, D_C_min, D_C_max, D, ...
    stratb, stratg, P_f_min, P_f_max, F, P_f, .143, 0, 1 , p_b);
    
end

%plotting
mean_process1 = mean(reshape(paths_price(1,:,:), S, M_sim), 2);
sd_process1 = std(reshape(paths_price(1,:,:), S, M_sim), 0, 2);
mean_process2 = mean(reshape(paths_price(2,:,:), S, M_sim), 2);
sd_process2 = std(reshape(paths_price(2,:,:), S, M_sim), 0, 2);
plot(2013:2062, mean_process1, 'b', 2013:2062, mean_process2,'r')
hold on
plot(2013:2062, mean_process1+ sd_process1, '--b', 2013:2062, mean_process1 - sd_process1, '--b' )
plot(2013:2062, mean_process1+ sd_process2, '--r', 2013:2062, mean_process1 - sd_process2, '--r' )
xlabel('Time')
ylabel('Share of clean energy')
title('First and second moments of time paths under two price processes')
hold off


%saving data
savefile = 'sim_price.mat';
save(savefile, 'output_price', 'paths_price');

% Variation in utility functions
% Economic utilities only but with different interest rates
util_type = 3;
process = 2;
p_b = .5;
discounts = [linspace(.05,.15, 21)', repmat(.04, 21,1)];
output_discounts = zeros(size(discounts,1), 4, 4);
paths_discounts = zeros(size(discounts,1), S, M_sim); % in case we want to examine the 
%trajectories instead of merely the aggregate output variables
estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process);
for ii=1:size(discounts,1)
    
    [stratb, stratg] = optimize_extraargs(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, lambdas, ideals, discounts(ii,:), util_type, ...
                              termlen , p_b, estrat, process);

    [output_discounts(ii,:,:) , paths_discounts(ii, :, :)] = run_sim(S, M_sim, ...
    P_f0 , process, 50, C, D_C_min, D_C_max, D, ...
    stratb, stratg, P_f_min, P_f_max, F, P_f, .143, 0, 1 , p_b);
    
end

%plotting
xlabels = 'Discount rate of brown party';
ylabel_1 = 'Clean energy share';
ylabel_2 = 'Annual change in clean energy by said party';
output = output_discounts;
param = discounts(:,1);


% The only thing to change below are the titles and file output names 
figure(1);
plot_output(output,param, 1, xlabels, ylabel_1)
title('Clean energy share in 2030 vs. discount rate brown party under pure econ. pref')


figure(2);
plot_output(output,param, 2, xlabels, ylabel_1)
title('Clean energy share in 2030 vs. discount rate brown party under pure econ. pref')

figure(3);
plot_output(output,param, 3, xlabels, ylabel_2)
title('Annual change in clean energy by green party vs. discount rate brown party under pure econ. pref')

figure(4);
plot_output(output,param, 4, xlabels, ylabel_2)
title('Annual change in clean energy by brown party vs. discount rate brown party under pure econ. pref')



%saving data
savefile = 'sim_discount.mat';
save(savefile, 'output_discount', 'paths_discount');
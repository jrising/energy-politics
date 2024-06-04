Q_const = 2281591; % 20000 TWh / year
C = 20; % Number of clean energy shares for planning
D_C_min = -.5; % Highest clean energy decrease
D_C_max = 1; % Highest clean energy increase
D = 100;
F=10;
P_f_min = 1000;
P_f_max = 6000;
P_f0 = 3860;
s_c0 = .143;  % In 2011 in the US it's 12.6% counting hydro. Without hydro it's more like 0.06.
N = 50;
termlen = 4;
ideals = [0, 1];

D_C = [0 linspace(D_C_min, D_C_max, D)/C];
S_C = linspace(0,1, 20);

% Parameters of interest as IVs: re-election probability, learning
% coefficient, lambdas
M = 100;
M_sim = 500; % to distinguish the # of iterations in our simulations (versus the # of iterations of players' mental simulations)
S = 100; % horizon for economically optimal
S2 = 50; % horizon for actors
alpha_wind = 0.35;
alpha_solar = .2; 
lambdas = [.01, .01];  
p_b = .5; 
process = 2;
discounts = [.05, .05];
util_type = 1;
declining = 0;


p_b=linspace(0,1,11);
lambda = 0.01;
output_p2 = zeros(size(p_b,2), 5, 4);
paths_p2 = zeros(size(p_b,2), S2, M_sim); 
elected = zeros(size(p_b,2), S2, M_sim);% in case we want to examine the 
%trajectories instead of merely the aggregate output variables
estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process, declining);
stratb = zeros(size(p_b,2),S2-1,C,F);
stratg = zeros(size(p_b,2),S2-1,C,F);
for ii=1:size(p_b,2)
    [stratb(ii,:,:,:), stratg(ii,:,:,:)] = optimize_nolimit(N, S2, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, [lambda lambda], ideals, discounts, util_type, ...
                              termlen , 'retro', 4, p_b(ii), estrat, process);
    
    [output_p(ii,:,:), paths_p(ii, :, :), elected(ii,:,:) ] = run_sim(S2, M_sim, P_f0 , 2, 50, C, D_C_min, D_C_max, D, ...
    squeeze(stratb(ii,:,:,:)), squeeze(stratg(ii,:,:,:)), P_f_min, P_f_max, F, .143, 0, 1 , p_b(ii));
    
end

xlabels = 'Probability of election';
ylabel_1 = 'Clean energy share';
ylabel_2 = 'Annual change in clean energy by said party';
output = output_p;
param = p_b;
% plot(2013:2062, reshape(paths_p(10,:,:), S, M_sim))
% The only thing to change below are the titles and file output names 
h1 = figure(1);
plot_output(output,param, 1, xlabels, ylabel_1)
title(sprintf('Clean energy share in 2030 vs. the brown party''s prob. of winning with lambda=%6.2f', lambda))

h2 = figure(2);
plot_output(output,param, 2, xlabels, ylabel_1)
title(sprintf('Clean energy share in 2050 vs. the brown party''s prob of winning  with lambda=%6.2f', lambda))

h3 = figure(3);
plot_output(output,param, 3, xlabels, ylabel_2)
title(sprintf('Annual change in clean energy by green party vs. the brown party''s prob. of winning with lambda=%6.2f', lambda))


h4 = figure(4);
plot_output(output,param, 4, xlabels, ylabel_2)
title(sprintf('Annual change in clean energy by brown party vs. the brown party''s prob. of winning with lambda=%6.2f', lambda))


% To check that there is nothing strange with the frequency of elections
for ii = 1:size(p_b,2)
    figure(5)
    subplot(2,2,1)
    hist(squeeze(sum(elected(2,:,:),2)))
    title('p = 0.1')
    subplot(2,2,2)
    hist(squeeze(sum(elected(4,:,:),2)))
    title('p = 0.3')
    subplot(2,2,3)
    hist(squeeze(sum(elected(5,:,:),2)))
    title('p = 0.4')
    subplot(2,2,4)
    hist(squeeze(sum(elected(6,:,:),2)))
    title('p = 0.5')
end

for ii = 1:size(p_b,2)
    figure(6)
    subplot(2,2,1)
    hist(squeeze(sum(elected(7,:,:),2)))
    title('p = 0.1')
    subplot(2,2,2)
    hist(squeeze(sum(elected(8,:,:),2)))
    title('p = 0.3')
    subplot(2,2,3)
    hist(squeeze(sum(elected(9,:,:),2)))
    title('p = 0.4')
    subplot(2,2,4)
    hist(squeeze(sum(elected(10,:,:),2)))
    title('p = 0.5')
end

% To check that there is nothing strange with strategies
for ii = 1:size(p_b,2)
    plot(1:C,squeeze(D_C(stratb(ii,20,:,5))))
    hold on
    plot(1:C,squeeze(D_C(stratg(ii,20,:,5))), 'r')
end

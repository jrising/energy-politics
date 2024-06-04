addpath('../lib');

do_economic_strat_graph = true;

close all;

figure(1);
title('Price of Fuel');
xlabel('Year');
ylabel('Price ($/TJ)');
hold on

for ii = 1:6
  P_f0 = 3860; % Fuel cost ($/TJ) (current price is $63/short ton. typically 24 MBtu/short ton and 1 TJ = 10^3 MBtu)

  [P_f] = simu(50, P_f0, 2);

  figure(1);
  plot(P_f);
end

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

if do_economic_strat_graph
  colors = bwcolor(F);
  P_f = linspace(P_f_min, P_f_max, F);
  clf
  for Fi = 1:F
    cc = plot_strat(estrat, C, D_C_min, D_C_max, D, '-', Fi, ...
                    colors(Fi, :));
    if sum(Fi == [1, 2, 3, 4, 5, 6, 10])
      text(2062.5, cc(end), ['$' num2str(round(P_f(Fi))) '/TJ'])
    end
  end
  %title('Economically optimal investment schedule vs. fuel price', ...
  %      'fontsize', 20);
  title('')
  xlabel('Year');
  ylabel('Renewable energy share (s)')
  axis([2013 2062 0 .6])
end

clf
plot_strat(estrat, C, D_C_min, D_C_max, D, 'y-');


% Experiment: The following two runs should give identical results
voteModel = 4;
vmArgs = .5;

[strat1_baser, strat2_baser] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.04 .04], [0 1], [.05 .05], 1, 4, 'baser', ...
                                                  voteModel, vmArgs, estrat, nan, 2);
plot_strat(strat1_baser, C, D_C_min, D_C_max, D, 'k-');
plot_strat(strat2_baser, C, D_C_min, D_C_max, D, 'g-');

[strat1_retro, strat2_retro] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.04 .04], [0 1], [.05 .05], 1, 4, 'retro', ...
                                                  voteModel, vmArgs, estrat, 2);
plot_strat(strat1_retro, C, D_C_min, D_C_max, D, 'k-');
plot_strat(strat2_retro, C, D_C_min, D_C_max, D, 'g-');

% Collect optional VV2s for election testing below
[strat1_coghi, strat2_coghi, VV2_1, VV2_2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.04 .04], [0 1], [.05 .05], 1, 4, 'coghi', ...
                                                  voteModel, vmArgs, estrat, nan, 2);
plot_strat(strat1_coghi, C, D_C_min, D_C_max, D, 'k-');
plot_strat(strat2_coghi, C, D_C_min, D_C_max, D, 'g-');

figure;
subplot(1, 3, 1);
surf(squeeze(strat1_baser(18, :, :)))
subplot(1, 3, 2);
surf(squeeze(strat1_retro(18, :, :)))
subplot(1, 3, 3);
surf(squeeze(strat1_coghi(18, :, :)))

% Experiment: Retrospective Model

voteModel = 5;
vmArgs = [.5 .1];

[strat1_retro, strat2_retro] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retro', ...
                                                  voteModel, vmArgs, estrat, 2);
plot_strat(strat1, C, D_C_min, D_C_max, D, 'r-');
plot_strat(strat2, C, D_C_min, D_C_max, D, 'b-');

% Experiment: Full Election Model

[strat1v, strat2v] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                      Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'coghi', ...
                                      voteModel, vmArgs, estrat, 2);
plot_strat(strat1v, C, D_C_min, D_C_max, D, 'r-');
plot_strat(strat2v, C, D_C_min, D_C_max, D, 'b-');

% Experiment: Compare limit and nolimit results

[strat1, strat2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                    Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'coghi', ...
                                    5, 0.5, estrat, 2);
plot_strat(strat1, C, D_C_min, D_C_max, D, 'k-');
plot_strat(strat2, C, D_C_min, D_C_max, D, 'g-');

[strat1, strat2] = optimize_limit(50, 50, 8, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'coghi', ...
                                  4, 0.5, estrat, 2);
plot_strat(strat1, C, D_C_min, D_C_max, D, 'm-');
plot_strat(strat2, C, D_C_min, D_C_max, D, 'y-');

figure
for ii = 1:10
  P_f0 = 3860; % Fuel cost ($/TJ)
  [P_f] = simu(50, P_f0, 2);

  s_c = simustrat(50, C, D_C_min, D_C_max, D, strat1, strat2, ...
                  P_f_min, P_f_max, F, P_f, .143, 0, 1);
  plot(s_c);
  hold on
end

%%% Elections

% Test election mechanics
% Test 1: Election probabilities
s_self = linspace(0, 1, 100);
s_other = repmat(.5, 1, 100);
b = .1;
lambda = .1;
figure
hold on
plot(s_self, election(0, 1, s_self, s_other, .6))
plot(s_self, election(1, 1, s_self, s_other, .6))
plot(s_self, election(2, 1, s_self, s_other, .6))
plot(s_self, election(3, 1, s_self, s_other, .6))
plot(s_self, election(4, 1, s_self, s_other, .6, .5))
plot(s_self, election(5, 1, s_self, s_other, .6, [lambda b]))
plot(s_self, election(6, 1, s_self, s_other, .6, [lambda b]))
plot(s_self, election(7, 1, s_self, s_other, .6, [lambda b]))
title('Probability of Party 1 Election', 'fontsize', 20);
xlabel('Party 2 Proposal');

P_f = linspace(P_f_min, P_f_max, F);

Fi = 5;
Fi2s = [];
for ii = 1:50
  [P_f2] = simustep(P_f(Fi), 2);
  Fi2s(ii) = discrete(P_f2, P_f_min, P_f_max, F);  % says in which bin of the discretized coal price space P_f2 falls
end

% Test 2: Responding to votes
[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);
S_C = linspace(0, 1, C);
dc = [0 linspace(D_C_min, D_C_max, D)/C]; % change in clean energy
                                          % share, in terms of C indices
dcef = .64 - S_C(state1(:));

voteModel = 5;
vmArgs = [.5 .1];

actions = electprop(Fi2s, 1, VV2_1, ones(1, 20), dcef, ...
                    state1, state2a, state2b, xprob2, q_c, Q_const, ...
                    .01, 0, .05, 1, voteModel, 1, vmArgs);

figure
hold on
plot(linspace(0, 1, 20), dc(strat1_retro(1, :, 5)), 'r');
plot(linspace(0, 1, 20), dc(actions), 'b');
plot(linspace(0, 1, 20), dc(strat1v(1,:,5)), 'b');

actions = electprop(Fi2s, 1, VV2_2, ones(1, 20), dcef, ...
                    state1, state2a, state2b, xprob2, q_c, Q_const, ...
                    .01, 1, .05, 1, voteModel, 0, vmArgs);

plot(linspace(0, 1, 20), dc(strat2(1, :, 5)), 'r');
plot(linspace(0, 1, 20), dc(actions), 'b');

title('Effects of election strategizing', 'fontsize', 20)
xlabel('Initial clean energy share');

% Test 3: Election strategizing
voteModel = 5;
vmArgs = [.5 .1];

P_f = linspace(P_f_min, P_f_max, F);

Fi = 5;
Fi2s = [];
for ii = 1:50
  [P_f2] = simustep(P_f(Fi), 2);
  Fi2s(ii) = discrete(P_f2, P_f_min, P_f_max, F);  % says in which bin of the discretized coal price space P_f2 falls
end

[state1, state2a, state2b, xprob2, q_c, q_f] = make_actions(C, D_C_min, ...
                                                  D_C_max, D, Q_const);
eactions = squeeze(estrat(1, state1, :));  % retrieves the best economic action for each of the 20 states (as indices).
dc = [0 linspace(D_C_min, D_C_max, D)/C];
dcef = dc(eactions(:, Fi));

actions = electprop(Fi2s, 1, VV2_1, squeeze(strat2(1, :, 5)), dcef, ...
                    state1, state2a, state2b, xprob2, q_c, Q_const, ...
                    .01, 0, .05, 1, voteModel, 1, vmArgs);

figure
hold on
plot(linspace(0, 1, 20), dc(strat1(1, :, 5)), 'r');
plot(linspace(0, 1, 20), dc(actions), 'b');

actions = electprop(Fi2s, 1, VV2_2, actions, dcef, ...
                    state1, state2a, state2b, xprob2, q_c, Q_const, ...
                    .01, 1, .05, 1, voteModel, 0, vmArgs);

plot(linspace(0, 1, 20), dc(strat2(1, :, 5)), 'r');
plot(linspace(0, 1, 20), dc(actions), 'b');

title('Effects of election strategizing', 'fontsize', 20)
xlabel('Initial clean energy share');

% Below here is not used!

plot(simuvote(Q_const, .25, linspace(0, 1, 100)*Q_const, (1 - linspace(0, 1, 100))*Q_const));



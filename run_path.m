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

voteModel = 5;
vmArgs = [.1 .5];

% Determine preferred strategies
prefstrats = preferred_strategies(50, C, D_C_min, D_C_max, D, F, ...
                                  Q_const, [.01 .01], [0 1], 1, estrat);
prefstrats_eideal = prefstrats;
prefstrats_eideal(:, :, :, 1) = estrat;
prefstrats_eideal(:, :, :, 2) = estrat;

S_C = linspace(0, 1, C);
D_C = [0 linspace(D_C_min, D_C_max, D)/C];

[strat1_retro, strat2_retro] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, [.01 .01], [0 1], [.05 .05], 1, 4, 'retex', ...
                                                  voteModel, vmArgs, estrat, prefstrats, 2);

% Experiment 1 - look at simulations
% Also collect values
P_f = 3860 * ones(1, 50); % Fuel cost ($/TJ)

figure
year = 2013:2062;
colors = 'rg';

for e1 = 0:1
  for e2 = 0:1
    for e3 = 0:1
      for e4 = 0:1
        for e5 = 0:1
          for e6 = 0:1
            for e7 = 0:1
              [s_c, d_c_b, d_c_g, elected] = simustrat(28, 28, C, D_C_min, D_C_max, D, strat1_retro, strat2_retro, ...
                                                       P_f_min, P_f_max, F, P_f, .143, e1, 2, [e2 e3 e4 e5 e6 e7]);
              for t = 1:27
                plot(year(t:t+1), s_c(t:t+1), colors(elected(t+1)+1));
                hold on
              end
            end
          end
        end
      end
    end
  end
end
colors = 'kb';
[s_c, d_c_b, d_c_g, elected] = simustrat(28, 28, C, D_C_min, D_C_max, D, strat1_retro, strat2_retro, ...
                                         P_f_min, P_f_max, F, P_f, .143, 0, 2, [0 0 0 1 1 1]);
for t = 1:27
  plot(year(t:t+1), s_c(t:t+1), colors(elected(t+1)+1), 'LineWidth', 2);
  hold on
end
[s_c, d_c_b, d_c_g, elected] = simustrat(28, 28, C, D_C_min, D_C_max, D, strat1_retro, strat2_retro, ...
                                         P_f_min, P_f_max, F, P_f, .143, 1, 2, [1 1 0 0 0 0]);
for t = 1:27
  plot(year(t:t+1), s_c(t:t+1), colors(elected(t+1)+1), 'LineWidth', 2);
  hold on
end

title('Renewable Energy Paths across Election Outcomes', 'fontsize', 20);
xlabel('Year');
ylabel('Renewable Energy Share');

% Make vector field of changes
figure
dce_b = zeros(13, 13);
dce_b_count = zeros(13, 13);
dce_g = zeros(13, 13);
dce_g_count = zeros(13, 13);

for e1 = 0:1
  for e2 = 0:1
    for e3 = 0:1
      for e4 = 0:1
        for e5 = 0:1
          for e6 = 0:1
            for e7 = 0:1
              for e8 = 0:1
                for e9 = 0:1
                  for e10 = 0:1
                    for e11 = 0:1
                      for e12 = 0:1
                        winners = [e1 e2 e3 e4 e5 e6 e7 e8 e9 ...
                                   e10 e11 e12];
                        [s_c, d_c_b, d_c_g, elected] = simustrat(48, 48, C, D_C_min, D_C_max, D, strat1_retro, strat2_retro, ...
                                                                 P_f_min, P_f_max, F, P_f, .143, e1, 2, winners(2:end));
              
                        bs = [0 cumsum(1 - winners)];
                        gs = [0 cumsum(winners)];
                        for s = 1:12
                          dce_b(bs(s)+1, gs(s)+1) = dce_b(bs(s)+1, gs(s)+1) + sum(d_c_b((s-1)*4+1:s*4));
                          dce_b_count(bs(s)+1, gs(s)+1) = dce_b_count(bs(s)+1, gs(s)+1) + 1;
                          dce_g(bs(s)+1, gs(s)+1) = dce_g(bs(s)+1, gs(s)+1) + sum(d_c_g((s-1)*4+1:s*4));
                          dce_g_count(bs(s)+1, gs(s)+1) = dce_g_count(bs(s)+1, gs(s)+1) + 1;
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

figure;
% NOTE: we swap rows and columns here (so brown is along bottom)
quiver(repmat(0:7, 8, 1)', repmat(0:7, 8, 1), dce_b(1:8, 1:8) ./ dce_b_count(1:8, 1:8), dce_g(1:8, 1:8) ./ dce_g_count(1:8, 1:8))
grid
axis equal
axis([0 8 0 8])

for ii = 0:7
  for jj = 0:7
    if dce_g_count(ii+1, jj+1) > 0
      text(ii + 10 * dce_b(ii+1, jj+1) ./ dce_b_count(ii+1, jj+1) + .1, jj + 10 * dce_g(ii+1, jj+1) ./ dce_g_count(ii+1, jj+1) - .05, [num2str(round(1000*sqrt((dce_g(ii+1, jj+1) ./ dce_g_count(ii+1, jj+1))^2 + ...
                                                        (dce_b(ii+1, jj+1) ./ dce_b_count(ii+1, jj+1))^2))/10) '%'])
      text(ii + .12, jj + .11, [num2str(round((180 / pi) * atan2(dce_g(ii+1, jj+1) ./ dce_g_count(ii+1, jj+1), ...
                                 dce_b(ii+1, jj+1) ./ dce_b_count(ii+1, jj+1)))) '\circ'], ...
           'Color', 'r')
    end
  end
end
xlabel('Brown Party Victories')
ylabel('Green Party Victories')
title('Renewable Energy Vector Field', 'fontsize', 20)

% Calculate curl
% swap rows and columns, so brown victories are along columns
values = curl(100*dce_b(1:8, 1:8) ./ dce_b_count(1:8, 1:8), 100*dce_g(1:8, 1:8) ./ dce_g_count(1:8, 1:8))';
[nr,nc] = size(values);

pcolor(0:8, 0:8, [values nan(nr,1); nan(1,nc+1)]);
colorbar

title('Curl of the Renewable Energy Vector Field (in %)', 'fontsize', 20)
xlabel('Brown Party Victories')
ylabel('Green Party Victories')

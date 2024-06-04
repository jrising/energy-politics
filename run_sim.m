function [output, paths, elected, P_f] = run_sim( S, M_sim, P_f0, process, R, C, D_C_min, D_C_max, D, stratb, stratg, ...
                                        P_f_min, P_f_max, F,  ...
                                        s_c0, elected0, election_rule,  p_b)
output = zeros(5,4);                                    
paths = zeros(S, M_sim);
gr_ac = zeros(S, M_sim); % green actions every year
br_ac = zeros(S, M_sim);  % brown actions every year
elected = zeros(S,M_sim);
P_f = zeros(S,M_sim);
for ii=1:M_sim
    P_f(:,ii) = simu(S, P_f0, process)';
    [paths(:,ii),  br_ac(:,ii),gr_ac(:, ii), elected(:,ii)] = simustrat(S, R, C, D_C_min, D_C_max, D, stratb, stratg, ...
                                        P_f_min, P_f_max, F, P_f(:,ii), ...
                                        s_c0, elected0, election_rule,  p_b);  
end
    output(1, 1) = mean(paths(30-13,:));  
    output(2, 1) = std(paths(30-13,:));
    output(3, 1) = prctile(paths(30-13,:), 2.5);
    output(4, 1) = prctile(paths(30-13,:), 97.5);
    output(5, 1) = median(paths(30-13,:));
    output(1, 2) = mean(paths(50-13,:));  
    output(2, 2) = std(paths(50-13,:));
    output(3, 2) = prctile(paths(50-13,:), 2.5);
    output(4, 2) = prctile(paths(50-13,:), 97.5);
    output(5, 1) = median(paths(50-13,:));
    output(1, 3) = mean(gr_ac(elected==1));
    output(2, 3) = std(gr_ac(elected==1));
    output(3, 3) = prctile(gr_ac(elected==1), 2.5);
    output(4, 3) = prctile(gr_ac(elected==1), 97.5);
    output(5, 1) = median(gr_ac(elected==1));
    output(1, 4) = mean(br_ac(elected==0));
    output(2, 4) = std(br_ac(elected==0));
    output(3, 4) = prctile(br_ac(elected==1), 2.5);
    output(4, 4) = prctile(br_ac(elected==1), 97.5);
    output(5, 1) = median(br_ac(elected==1));
    
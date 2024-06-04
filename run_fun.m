function [estrat,strat_1,strat_2]=run_fun(N, S, C, D_C_min, D_C_max, D, ...
                                        P_f_min, P_f_max, F, Q_const, ...
                                        alpha_wind, alpha_solar, lambdas, ...
                                        ideals, termlen, p_b , process, declining)
estrat = optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, ...
                        F, Q_const, alpha_wind, alpha_solar, process, declining);
                    
[strat_1, strat_2] = optimize(N, S, C, D_C_min, D_C_max, D, P_f_min, ...
                              P_f_max, F, Q_const, lambdas, ideals, ...
                              termlen , p_b, estrat);


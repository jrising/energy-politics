function [strat, inits] = call_optimize(args)
% Takes the same arguments as optimize, but as a cell array

[strat, inits] = optimize(args{1}, args{2}, args{3}, args{4}, args{5}, ...
                          args{6}, args{7}, args{8}, args{9}, args{10}, ...
                          args{11})
# energy-politics
Forward looking optimization of energy and politics

## Common variables
 - P_f: price of fuel (discretized)
 - Fi: index of a price in the linearized vector
 - d_c: the % of Q_const that is being converted to and from clean energy (within the allowable range, that is within D_C_min/C to D_C_max/C)
 - D_C_min: highest clean energy decrease
 - D_C_max: the maximum increase upwards in clean energy share on the (0,1,C) scale (that is 1 corresponds to 0.05 increase, 2 corresponds to 0.1 increase).
 - C: number of clean energy shares for planning (coarse-graining used to represent the states of the world regarding clean energy share)
 - S planning horizon
 - D: discretization of the change in clean energy share action variable.
 - Q: total capacity (in MW)
 - q_c: clean energy investment (in MW)
 - q_f: fuel energy investment (in MW)
 - s_c: clean energy share
 - process: price process
 - util_type : one of two utility functions
 - VV2_1,2: arrays of 20x10x2 giving maximized continuation values (the third dimension allows to get the maximized continuation values assuming being in power and not in power respectively in the next period)

## Functions: 
 - discrete (xx, xmin, xmax, num): retrieves the index of a value in a linear discretized array

 - ecost(s_c, Q, q_c, q_f, P_f, alpha_wind, alpha_solar)
This function returns the cost of a given clean energy share.

 - election(voteModel, inPower, s_self, s_other, s_e, args): returns the probability of winning given the combination of states of world and actions (s_self and s_other). args holds lambda and b for models 5,6 and 7. s_e doesn't seem to be used.

 - electprop(Fi2s, Pi, VV2, other_actions, dcef, state1, state2a, state2b, xprob2, q_c, Q_const, lambda, ideal, discount, util_type, voteModel, inPower, voteArgs)
This function returns a party's optimal proposed action for an election.

 - make_actions(C, D_C_min, D_C_max, D, Q_const)
returns matrices with a row for each action and a column for each current state of the world (indices from 1 to 20, to represent the S_C bins). These matrices together give us the states of the world that may be reached in the next state (for each action x prior state combination) as well as the investment level state2a, state2b, xprob2: probabilistic

 - optimize_cost(N, S, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, Q_const, alpha_wind, alpha_solar, process)
returns an S x C x F matrix that gives the economically optimal action.

 - simustrat:
returns the realized s_c, d_c_b, d_c_g, d_c (given who was actually elected)

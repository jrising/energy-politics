nom_cost2=load('coaldata/coal_deliveredcost_nom_cents_Mbtu.txt'); % cost of delivered energy in nominal cents per MBtu
nom_cost2=load('coaldata/coal_undeliveredcost_nom_cents_Mbtu.txt');
cpi=load('coaldata/deflators.txt');
real_cost=0.01 * nom_cost2 ./ cpi * 201.6 ; % cost of delivered energy in real dollars per MBtu
real_cost=real_cost * 947.81; % cost of delivered energy in real dollars per TJ (947.81 MBtu/TJ)

% Fit AR(1)
A=[ones(length(real_cost)-1,1), log(real_cost(1:length(real_cost)-1)')];
Y=log(real_cost(2:end)');
beta=inv(A'*A)*A'*Y;
error=Y-A*beta;
sigma=error'*error/(length(Y)-2);
var_beta=sigma*inv(A'*A);
st_error=diag(var_beta.^(1/2));
ci=st_error.*1.96
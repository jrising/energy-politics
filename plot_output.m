function plot_output(output,param, var, xlabels, ylabels, inter)
plot(param, output(:,1,var))
hold on
%plot(param, output(:,3,var), '--')
%plot(param, output(:,4,var), '--')
plot(param, output(:,1,var)+output(:,2,var), '--')
plot(param, output(:,1,var)-output(:,2,var), '--')
xlabel(xlabels)
ylabel(ylabels)
ylim(inter)
hold off
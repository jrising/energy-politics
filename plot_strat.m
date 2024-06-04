function cc = plot_strat(strat, C, D_C_min, D_C_max, D, linespec, ...
                         Fi, color)

if nargin < 6
  linespec = 'b-';
end
if nargin < 7
  Fi = 5;
end

D_C = [0 linspace(D_C_min, D_C_max, D)/C];
cc = .143;
ac = 0;
dc = discrete(cc, 0, 1, C);
for ii = 2:50
  before = discrete(cc(ii-1), 0, 1, C);
  ac(ii) = strat(ii-1, before, Fi);
  cc(ii) = cc(ii-1) + D_C(ac(ii));
end

%clf
if nargin < 8
  plot(2013:2062, cc, linespec)
else
  plot(2013:2062, cc, linespec, 'Color', color)
end
title('Clean Energy Share', 'fontsize', 20);
hold on
%plot([2013 2050 2050], [cc(38) cc(38) 0], linespec)
%stem((2013 + 3.5):4:2062, ones(length((2013 + 3.5):4:2062)), 'r')

axis tight

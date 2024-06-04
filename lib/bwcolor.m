function rgb = bwcolor(n)

tored = floor(n*5/6);
toblack = n - tored;
hsvs = [[linspace(1.0/6.0, 1, tored)'; ones(toblack, 1)] ones(n, 1) ...
        [linspace(1, .5, tored)'; linspace(.5, 0, toblack)']];
rgb = hsv2rgb(hsvs);

sums = rgb * ones(3, 1);
minsum = 2.0;
for ii = 1:length(sums) - 1
  minsum = min(minsum, sums(ii));
  rgb(ii, :) = rgb(ii, :) * minsum / sums(ii);
end
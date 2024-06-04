function yy = payoff(s_c, lambda, s_C, s_E, util_type)

if util_type ==1
    yy = -(s_c - (lambda * s_C + (1 - lambda) * s_E)).^2;
elseif util_type ==2
    yy = -lambda*(s_c -  s_C).^2 - (1-lambda)*(s_c - s_E).^2;
elseif util_type ==3
    yy = -(s_c - s_E).^2;  % economic only
end

function [idx] = find_index(scenarii,scenario)
for ii=1:length(scenarii)
    count = 0;
    for jj=1:length(scenario)
        if abs(scenarii(ii,jj)-scenario(jj))<1e-6;
            count = count+1;
        end
    end
    if count==length(scenario)
        idx=ii;
    end
end
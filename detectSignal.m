function [answer] = detectSignal(sample_data_orig)

for ind1=1:100:(length(sample_data_orig)-(length(sample_data_orig)/10))
    sample_data = sample_data_orig(ind1:ind1-1+(length(sample_data_orig)/10));
    sample_abs = abs(sample_data);
    sample_mean = mean(sample_abs);
    sample_max = max(sample_abs);

    sample_p = sample_max/sample_mean;

    if (sample_p > 8)
        answer = 1;
        return;
    else
        answer = 0;
    end;
end;
answer = 0;
return;